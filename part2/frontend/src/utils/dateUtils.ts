/**
 * Converts a month input value (YYYY-MM) to a date string (YYYY-MM-01) for API submission
 * This ensures the date is always the first day of the month in UTC
 */
export const monthInputToDateString = (monthInput: string): string => {
  // Month input format is "YYYY-MM"
  // We want to send "YYYY-MM-01" to the backend
  return `${monthInput}-01`
}

/**
 * Converts a date string (YYYY-MM-DD) to a month input value (YYYY-MM)
 * This is used to populate the month picker from stored dates
 */
export const dateStringToMonthInput = (dateString: string): string => {
  // Extract YYYY-MM from YYYY-MM-DD
  return dateString.substring(0, 7)
}

/**
 * Formats a date string for display as "Month Year" in UTC
 * Avoids timezone shifts that can occur with native Date parsing
 */
export const formatDateAsMonthYear = (dateString: string): string => {
  // Parse the date components to avoid timezone issues
  const [year, month, day] = dateString.split('-').map(Number)

  // Create a date in UTC
  const date = new Date(Date.UTC(year, month - 1, day || 1))

  // Format in UTC timezone
  return date.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'long',
    timeZone: 'UTC'
  })
}
