import React, { useEffect, useRef, useState } from 'react'

const WaveformVisualization = ({ audioBuffer }) => {
  const element = useRef(null)
  const canvas = element.current

  const [dimensions, setDimensions] = useState()

  useEffect(() => {
    if (canvas === null) {
      return
    }

    let timer

    function setContainerDimensions() {
      setDimensions({
        width: canvas.width,
        height: canvas.height
      })
    }

    function handleResize() {
      if (timer === undefined) {
        timer = window.setTimeout(() => {
          setContainerDimensions()

          timer = undefined
        }, 66)
      }
    }

    const resizeObserver = new ResizeObserver(handleResize)
    resizeObserver.observe(canvas)

    setContainerDimensions()

    return () => {
      resizeObserver.unobserve(canvas)

      window.clearTimeout(timer)
    }
  }, [canvas, audioBuffer])

  useEffect(() => {
    if (canvas === null) {
      return
    }

    if (dimensions === undefined) {
      return
    }
    const { width, height } = dimensions

    const ctx = canvas.getContext('2d')
    ctx.clearRect(0, 0, width, height)

    if (audioBuffer === undefined) {
      return
    }

    // Get audio data
    const channelData = audioBuffer.getChannelData(0)
    const bufferLength = channelData.length

    // Calculate samples per pixel
    const samplesPerPixel = Math.ceil(bufferLength / width)

    // Draw the waveform
    ctx.beginPath()
    ctx.strokeStyle = 'rgba(0,255,255,1)' // Cyan color
    ctx.lineWidth = 2

    // Draw pixel by pixel
    for (let x = 0; x < width; x++) {
      // Calculate sample range for this pixel
      const startIndex = Math.floor(x * samplesPerPixel)
      const endIndex = Math.min(startIndex + samplesPerPixel, bufferLength)

      // Find min and max in this range
      let min = 0, max = 0
      for (let i = startIndex; i < endIndex; i++) {
        const sample = channelData[i]
        if (sample < min) min = sample
        if (sample > max) max = sample
      }

      // Convert to canvas coordinates
      const y1 = ((min + 1) / 2) * height
      const y2 = ((max + 1) / 2) * height

      // Draw vertical line from min to max
      ctx.moveTo(x, y1)
      ctx.lineTo(x, y2)
    }

    ctx.stroke()

  }, [canvas, dimensions, audioBuffer])

  return (
    <div className="p-4 relative w-full h-full">
      <canvas ref={element} className="w-full h-full relative">
      </canvas>
    </div>
  )
}

export default WaveformVisualization