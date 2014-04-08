json.partial! @user

if can?(:update,@user)
  json.(@user,:email,:auth_token,:provider)
end