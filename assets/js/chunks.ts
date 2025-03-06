function parseVectorToFloat(value) {
  return JSON.parse(value).map(val => val * 127.5 + 127.5) // Reverse normalization
}

function floatsToBytes(floatArray) {
  return new Uint8Array(floatArray.map(val => Math.round(val)))
}

export function arrayFromChunks(chunks) {
  // Parse vector values and convert back to bytes
  const byteArrays = chunks.map(chunk => {
    const floatValues = parseVectorToFloat(chunk.value)

    return floatsToBytes(floatValues)
  })

  // Concatenate all byte arrays into one
  const totalLength = byteArrays.reduce((sum, arr) => sum + arr.length, 0)
  const concatenated = new Uint8Array(totalLength)

  let offset = 0
  for (const byteArray of byteArrays) {
    concatenated.set(byteArray, offset)
    offset += byteArray.length
  }

  return concatenated
}