class Users::OrdersController < ApplicationController
  before_action :set_order, only: [ :show, :charge, :cancel ]
  before_action :set_phone_and_vcode, only: [ :new, :create ]
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
    fallback_redirect and return unless @order
    if wechat_request? || debug_wechat?
      url = request.original_url
      gon.push(auth_client(url))
    end
    set_pricing_for_contracted
  end

  # GET /orders/new
  def new
    gray_background
    set_sms_zone_hidden_class
    @order ||= current_user.orders.build(arrives_at: 1.hour.from_now)
    set_arrives_at_shift
    set_pricing_for_new
    set_address
  end

  # POST /orders
  def create
    @order = current_user.orders.build(order_params)
    set_arrives_at_shift
    verify_vcode
    if @order.request && @order.save_with_user_phone(@phone)
      redirect_to [ :user, @order ], notice: t('.order_success')
    else
      new
      render :new
    end
  end

  # PUT /orders/:id/cancel
  def cancel
    fallback_redirect and return unless @order
    @order.canceler = current_user
    if @order.cancel && @order.save
      redirect_to [ :user, @order ], notice: t('.cancel_order_success')
    else
      redirect_to [ :user, @order ], notice: t('.cancel_order_failure')
    end
  end

  # GET /orders/:id/charge
  def charge
    if @order.valid_pingpp_charge? && !@order.payment_expired?
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

  def verify_vcode
    errors.clear
    return if current_user.phone_verified? && current_user.phone == @phone
    vcode_sent = current_user.phone_vcode.value
    sent_times = current_user.phone_vcode_sent_times_in_hour
    case
    when @phone.blank?
      errors.add(:base, '手机号码为空')
    when vcode_sent.nil? && sent_times < 3
      errors.add(:base, '请您重新发送手机验证码')
    when vcode_sent.nil?
      errors.add(:base, '暂时无法发送验证码，请稍后再试')
    when @vcode != vcode_sent
      errors.add(:base, '手机验证码错误')
    end
  end

  def errors
    @order.retained_errors
  end

  def set_order
    @order = Order.find(params[:id])
    @order = nil unless @order.user == current_user
  end

  def set_address
    address = @order.address
    if address.blank?
      opts = current_user.primary_address.try(:attribute_hash) || {}
      address = @order.build_address(opts)
    end

    @city_code = address.try(:city_code) || '430100'
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
end
