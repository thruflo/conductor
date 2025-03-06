import React, { useEffect, useRef, useState } from 'react'

const WaveformAnimation = ({ dataArray }) => {
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
  }, [canvas, dataArray])

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

    if (dataArray === undefined) {
      return
    }
    const bufferLength = dataArray.byteLength

    // Draw waveform
    ctx.lineWidth = 2
    ctx.strokeStyle = '#00ffff'
    ctx.beginPath()

    const sliceWidth = width * 1.0 / bufferLength
    let x = 0

    for (let i = 0; i < bufferLength; i++) {
        const v = dataArray[i] / 128.0
        const y = v * height / 2

        if (i === 0) {
          ctx.moveTo(x, y)
        } else {
          ctx.lineTo(x, y)
        }

        x += sliceWidth
    }

    ctx.lineTo(width, height / 2)
    ctx.stroke()
  }, [canvas, dimensions, dataArray])

  return (
    <div className="p-4 relative w-full h-full">
      <canvas ref={element} className="w-full h-full relative">
      </canvas>
    </div>
  )
}

export default WaveformAnimation