require "administrate/base_dashboard"

class OrderDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    user: Field::BelongsTo,
    handyman: Field::BelongsTo,
    transferee_order: Field::BelongsTo.with_options(class_name: "Order"),
    transferor: Field::BelongsTo.with_options(class_name: "Account"),
    canceler: Field::BelongsTo.with_options(class_name: "Account"),
    address: Field::HasOne,
    payments: Field::HasMany,
    valid_payment: Field::HasOne,
    ongoing_payment: Field::HasOne,
    id: Field::Number,
    taxon_code: Field::String,
    content: Field::String,
    arrives_at: Field::DateTime,
    contracted_at: Field::DateTime,
    completed_at: Field::DateTime,
    user_total: Field::String,
    payment_total: Field::String,
    user_promo_total: Field::String,
    handyman_bonus_total: Field::String,
    handyman_total: Field::String,
    transferee_order_id: Field::Number,
    transfer_type: Field::String,
    transfer_reason: Field::String,
    transferred_at: Field::DateTime,
    transferor_id: Field::Number,
    cancel_type: Field::String,
    cancel_reason: Field::String,
    canceled_at: Field::DateTime,
    canceler_id: Field::Number,
    rating: Field::Number,
    rating_content: Field::String,
    rated_at: Field::DateTime,
    report_type: Field::String,
    report_content: Field::String,
    reported_at: Field::DateTime,
    state: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = [
    :user,
    :handyman,
    :state,
    :user_total,
    :created_at,
    :updated_at,
    :taxon_code,
    :content
  ]

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = [
    :user,
    :handyman,
    :transferee_order,
    :transferor,
    :canceler,
    :address,
    :payments,
    :valid_payment,
    :ongoing_payment,
    :taxon_code,
    :content,
    :arrives_at,
    :contracted_at,
    :completed_at,
    :user_total,
    :payment_total,
    :user_promo_total,
    :handyman_bonus_total,
    :handyman_total,
    :transferee_order_id,
    :transfer_type,
    :transfer_reason,
    :transferred_at,
    :transferor_id,
    :cancel_type,
    :cancel_reason,
    :canceled_at,
    :canceler_id,
    :rating,
    :rating_content,
    :rated_at,
    :report_type,
    :report_content,
    :reported_at,
    :state,
  ]
end
