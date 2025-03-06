/**
 * Time sync algorithm to calculate clock skew between client and server.
 * Uses multiple round-trip measurements to find the most accurate samples
 * based on network latency.
 *
 * Message format is optimized for size:
 * Client -> Server: [0, t1]     where 0 = sync_request, t1 = client timestamp
 * Server -> Client: [1, t1, s1]   where 1 = sync_response, t1 = original client timestamp, s1 = server timestamp
 */
class TimeSync {
  hook?
  minOneTripTime?
  clockSkewPromise?
  resolveClockSkew?
  scheduledTimePromise?
  resolveScheduledTime?

  constructor(abortSignal) {
    this.abortSignal = abortSignal
    this.handleAbort = this.handleAbort.bind(this)
    this.abortSignal?.addEventListener('abort', this.handleAbort)
    this.samples = []
    this.shouldStartOnConfigure = false
    this.hasStarted = false
    this.clockSkewPromise = new Promise(resolve => {
      this.resolveClockSkew = (skew) => {
        resolve(skew)
      }
    })
  }

  configure(hook, minOneTripTime) {
    this.hook = hook
    this.minOneTripTime = minOneTripTime

    if (this.shouldStartOnConfigure) {
      this.start()
    }
  }

  start() {
    this.scheduledTimePromise = new Promise(resolve => {
      this.resolveScheduledTime = resolve
    })

    if (this.hasStarted) {
      return
    }

    if (this.hook === undefined) {
      this.shouldStartOnConfigure = true

      return
    }

    this.hasStarted = true

    this.startSampling()
  }

  get clockSkew() {
    if (!this.hasStarted) {
      this.start()
    }

    return this.clockSkewPromise
  }

  get scheduledTime() {
    if (!this.scheduledTimePromise) {
      this.start()
    }

    return this.scheduledTimePromise
  }

  /**
   * Initiates the sampling process according to the following algorithm:
   * - Takes 4 samples every 10 seconds for 2 minutes (48 samples total)
   * - Stops early if 3 samples have combinedOffset < 30ms
   * - After 2 minutes, accepts 3 samples with combinedOffset < 50ms
   * - If no acceptable samples, continues for 1 more minute
   */
  async startSampling() {
    const INITIAL_ROUNDS = 8
    const SAMPLES_PER_ROUND = 5
    const SAMPLE_INTERVAL = 100
    const ROUND_INTERVAL = 3000
    const EXTRA_ROUNDS = 6

    const EXCELLENT_BELOW = 25 //ms
    const GOOD_BELOW = 50 //ms

    // Discard the first sample. It's always a warmup.
    await this.takeSample()

    for (let round = 0; round < INITIAL_ROUNDS; round++) {
      for (let sample = 0; sample < SAMPLES_PER_ROUND; sample++) {
        await this.takeSample()

        if (this.checkSamples(EXCELLENT_BELOW, 3)) {
          this.finalizeResult()

          return
        }

        if (sample < SAMPLES_PER_ROUND - 1) {
            await new Promise(resolve => setTimeout(resolve, SAMPLE_INTERVAL))
        }
      }

      if (round < INITIAL_ROUNDS - 1) {
        await new Promise(resolve => setTimeout(resolve, ROUND_INTERVAL))
      }
    }

    if (this.checkSamples(GOOD_BELOW, 3)) {
        this.finalizeResult()

        return
    }

    for (let round = 0; round < EXTRA_ROUNDS; round++) {
      for (let sample = 0; sample < SAMPLES_PER_ROUND; sample++) {
        await this.takeSample()

        if (this.checkSamples(GOOD_BELOW, 3)) {
          this.finalizeResult()

          return
        }

        if (sample < SAMPLES_PER_ROUND - 1) {
          await new Promise(resolve => setTimeout(resolve, SAMPLE_INTERVAL))
        }
      }

      if (round < EXTRA_ROUNDS - 1) {
        await new Promise(resolve => setTimeout(resolve, ROUND_INTERVAL))
      }
    }

    this.finalizeResult()
  }

  /**
   * Takes a single round-trip sample by:
   * 1. Recording client time t1
   * 2. Sending request to server
   * 3. Server responds with its time s1
   * 4. Recording client time t2 on response
   * 5. Calculating offsets and clock skew
   */
  async takeSample() {
    const t1 = Date.now()

    // Send sync request and await response
    const s1 = await this.hook.sendTime(t1)

    const t2 = Date.now()
    const roundTripTime = t2 - t1

    const offset1 = s1 - t1 - this.minOneTripTime
    const offset2 = t2 - s1 - this.minOneTripTime
    const combinedOffset = offset1 + offset2
    const clockSkew = (offset1 - offset2) / 2

    this.samples.push({ combinedOffset, clockSkew })
  }

  /**
   * Checks if we have enough samples meeting the quality threshold
   * @param {number} maxOffset - Maximum acceptable round trip offset
   * @param {number} requiredCount - Number of samples needed
   * @returns {boolean} True if we have enough qualifying samples
   */
  checkSamples(maxOffset, requiredCount) {
    const goodSamples = this.samples.filter(sample => sample.combinedOffset < maxOffset)

    return goodSamples.length >= requiredCount
  }

  /**
   * Calculates final clock skew from best samples and resolves the promise
   * Uses the 3 samples with lowest round trip offset
   */
  finalizeResult() {
    if (this.samples.length < 3) {
      return 0
    }

    // Sort samples by combinedOffset and take the best 3.
    const bestSamples = this.samples
      .sort((a, b) => a.combinedOffset - b.combinedOffset)
      .slice(0, 3)

    // Calculate mean clock skew from best samples
    const meanClockSkew = Math.round(
      bestSamples.reduce((sum, sample) =>
        sum + sample.clockSkew, 0) / bestSamples.length
    )

    this.resolveClockSkew(meanClockSkew)
  }

  /**
   * Handles abort signal by immediately using best available samples
   */
  handleAbort() {
    if (this.resolveClockSkew) {
      this.finalizeResult()
    }

    this.abortSignal?.removeEventListener('abort', this.handleAbort)
  }
}

export const timeSyncController = new AbortController()
export const timeSync = new TimeSync(timeSyncController.signal)
