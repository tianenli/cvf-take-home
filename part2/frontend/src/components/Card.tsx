import { ReactNode } from 'react'

interface CardProps {
  children: ReactNode
  className?: string
  title?: string
  action?: ReactNode
}

export default function Card({ children, className = '', title, action }: CardProps) {
  return (
    <div className={`bg-white rounded-lg shadow-sm border ${className}`}>
      {(title || action) && (
        <div className="px-6 py-4 border-b flex justify-between items-center">
          {title && <h2 className="text-lg font-semibold text-gray-900">{title}</h2>}
          {action && <div>{action}</div>}
        </div>
      )}
      <div className="p-6">{children}</div>
    </div>
  )
}
