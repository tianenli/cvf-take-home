class FundSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :created_at, :updated_at
end
