json.array!(@users) do |user|
  json.extract! user, :id, :full_name
  json.url user_url(user, format: :json)
end
