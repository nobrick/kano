class Users::OrdersController < ApplicationController
  before_action :gray_background, only: [ :show ]

  # GET /orders
  def index
    @orders = current_user.orders.includes(:handyman)
      .order(updated_at: :desc)
      .page(params[:page]).per(7)
    gray_background if @orders.present?
  end

  # GET /orders/:id
  def show
    fallback_redirect and return unless set_order
    if wechat_request? || debug_wechat?
      url = request.original_url
      gon.push(auth_client(url))
    end
    set_pricing_for_contracted
  end

  # GET /orders/new
  def new
    gray_background
    set_phone_and_vcode
    set_sms_zone_hidden_class
    build_order
    set_arrives_at_shift
    set_pricing_for_new
    set_address
  end

  # POST /orders
  def create
    if request_order_and_save_phone(@phone)
      set_workers_after_create
      redirect_to [ :user, @order ], notice: t('.order_success')
    else
      new
      render :new
    end
  end

  # PUT /orders/:id/cancel
  def cancel
    opts = { whiny_transition: false }
    transition = Order.serializable_trigger(:cancel, :save, opts) do
      fallback_redirect and return unless set_order
      @order.tap { |o| o.canceler = current_user }
    end

    if transition
      redirect_to [ :user, @order ], notice: t('.cancel_order_success')
    else
      redirect_to [ :user, @order ], notice: t('.cancel_order_failure')
    end
  end

  # GET /orders/:id/charge
  def charge
    if set_order && @order.valid_pingpp_charge? && !@order.payment_expired?
      render json: @order.pingpp_charge_json
    else
      render json: nil
    end
  end

  private

  def auth_client(url)
    user_wechat = UserWechatsController.wechat
    signature_options = user_wechat.jsapi_ticket.signature(url)
    {
      pingpp_charge: @order.pingpp_charge_json,
      order_id: @order.id,
      wechat: {
        appid: user_wechat.access_token.appid,
        timestamp: signature_options.fetch(:timestamp),
        noncestr: signature_options.fetch(:noncestr),
        signature: signature_options.fetch(:signature)
      }
    }
  end

  def build_order
    @order ||= current_user.orders.build(arrives_at: 1.hour.from_now)
    resend = resend_params[:resend]
    @order.assign_attributes(resend) if resend
  end

  def request_order_and_save_phone(phone)
    @order = current_user.orders.new(order_params)
    set_phone_and_vcode
    args = [ :save_with_user_phone, @phone ]
    @order.serializable_trigger(:request, args, {}) do
      set_arrives_at_shift
      verify_vcode
    end
  end

  def set_phone_and_vcode
    @vcode = params[:vcode]
    @phone = params[:phone] || current_user.phone
  end

  def set_sms_zone_hidden_class
    verified = current_user.phone_verified?
    if verified && @phone == current_user.phone
      @sms_zone_hidden_class = 'hidden'
    else
      @sms_zone_hidden_class = ''
    end
  end

  def set_workers_after_create
    expired_days = 14
    Order::ExpiredCancelingWorker.perform_in(expired_days.days, @order.id, expired_days)
    Order::NoContractRemindWorker.perform_in(15.minutes, @order.id)
  end

  def verify_vcode
    errors.clear
    return if current_user.phone_verified? && current_user.phone == @phone
    vcode_sent = current_user.phone_vcode.value
    sent_times = current_user.phone_vcode_sent_times_in_hour
    case
    when @phone.blank?
      errors.add(:base, t('.phone.blank'))
    when vcode_sent.nil? && sent_times < 3
      errors.add(:base, t('.phone.resend'))
    when vcode_sent.nil?
      errors.add(:base, t('.phone.unavailable'))
    when @vcode != vcode_sent
      errors.add(:base, t('.phone.invalid'))
    end
  end

  def errors
    @order.retained_errors
  end

  def set_order
    @order = Order.find_by(id: params[:id])
    if @order.try(:user) == current_user
      @order
    else
      @order = nil
    end
  end

  def set_address
    address = @order.address
    if address.blank?
      opts = current_user.primary_address.try(:attribute_hash) || {}
      address = @order.build_address(opts)
    end

    @city_code = address.try(:city_code) || '431000'
    @district_code = address.try(:code)
  end

  def set_pricing_for_new
    @prices_json = TaxonItem.prices_json
  end

  def set_pricing_for_contracted
    @pricing = @order.pricing(calculate: false) if @order.contracted?
  end

  def set_arrives_at_shift
    @arrives_at_shift = params.fetch(:arrives_at_shift, 0).to_i
    if @order.arrives_at
      date = @arrives_at_shift.days.since(Date.today)
      change = { year: date.year, month: date.month, day: date.day }
      @order.arrives_at = @order.arrives_at.change(change)
    end
  end

  def fallback_redirect
    redirect_to user_orders_url, notice: t('.request_failure')
  end

  def order_params
    params.require(:order).permit(
      :content,
      :arrives_at,
      :taxon_code,
      address_attributes: [ :code, :content ]
    )
  end

  def resend_params
    params.permit({ resend: [ :content, :taxon_code ] })
  end
end
