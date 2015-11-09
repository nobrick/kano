require "administrate/base_dashboard"

class HandymanDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    addresses: Field::HasMany,
    primary_address: Field::BelongsTo.with_options(class_name: "Address"),
    orders: Field::HasMany,
    balance_records: Field::HasMany,
    latest_balance_record: Field::HasOne,
    id: Field::Number,
    email: Field::String,
    encrypted_password: Field::String,
    phone: Field::String,
    reset_password_token: Field::String,
    reset_password_sent_at: Field::DateTime,
    remember_created_at: Field::DateTime,
    sign_in_count: Field::Number,
    current_sign_in_at: Field::DateTime,
    last_sign_in_at: Field::DateTime,
    current_sign_in_ip: Field::String,
    last_sign_in_ip: Field::String,
    admin: Field::Boolean,
    coins: Field::Number,
    name: Field::String,
    provider: Field::String,
    uid: Field::String,
    nickname: Field::String,
    gender: Field::String,
    wechat_headimgurl: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
    type: Field::String,
    primary_address_id: Field::Number,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :id,
    :uid,
    :name,
    :nickname,
    :phone,
    :email,
    :orders,
    :balance_records
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :addresses,
    :primary_address,
    :orders,
    :balance_records,
    :latest_balance_record,
    :email,
    :encrypted_password,
    :phone,
    :reset_password_token,
    :reset_password_sent_at,
    :remember_created_at,
    :sign_in_count,
    :current_sign_in_at,
    :last_sign_in_at,
    :current_sign_in_ip,
    :last_sign_in_ip,
    :admin,
    :coins,
    :name,
    :provider,
    :uid,
    :nickname,
    :gender,
    :wechat_headimgurl,
    :type,
    :primary_address_id,
  ]
end
