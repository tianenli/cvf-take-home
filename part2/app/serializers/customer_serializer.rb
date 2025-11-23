class CustomerSerializer < ActiveModel::Serializer
  attributes :id, :reference_id, :cohort_id, :created_at, :updated_at
end
