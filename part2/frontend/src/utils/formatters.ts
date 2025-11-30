export const formatCurrency = (value: number | null | undefined): string => {
  if (value === null || value === undefined) return '-'
  return `$${value.toLocaleString()}`
}

export const formatMonthYear = (dateString: string): string => {
  // Parse the date string as UTC to avoid timezone shifts
  // Expects format: YYYY-MM-DD
  const [year, month] = dateString.split('-').map(Number)
  const date = new Date(Date.UTC(year, month - 1, 1))
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    timeZone: 'UTC'
  })
}

export const formatPercentage = (value: number | null | undefined, decimals = 1): string => {
  if (value === null || value === undefined) return '-'
  return `${value.toFixed(decimals)}%`
}
