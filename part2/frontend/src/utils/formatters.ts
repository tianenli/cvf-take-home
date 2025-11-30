export const formatCurrency = (value: number | null | undefined): string => {
  if (value === null || value === undefined) return '-'
  return `$${value.toLocaleString()}`
}

export const formatMonthYear = (dateString: string): string => {
  const date = new Date(dateString)
  return date.toLocaleDateString('en-US', { year: 'numeric', month: 'long' })
}

export const formatPercentage = (value: number | null | undefined, decimals = 1): string => {
  if (value === null || value === undefined) return '-'
  return `${value.toFixed(decimals)}%`
}
