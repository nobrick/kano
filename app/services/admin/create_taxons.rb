class Admin::CreateTaxons
  def self.call(*args)
    new(*args).call
  end

  def initialize(handyman, taxon_codes, certified_by = nil, certified_params = {})
    @handyman = handyman
    @taxon_codes = taxon_codes
    @certified_by = certified_by
    @certified_params = certified_params
  end

  def call
    result = create_taxons
    return result if !result.success?
    certify_taxons(result.data)
  end

  def create_taxons
    return ::Shared::Failure.new("没有选择技能或欲创建的技能已经存在") if taxon_to_create.empty?

    taxons = @handyman.taxons.create(taxon_to_create.map{ |e| { code: e , cert_requested_at: Time.now } })

    invalid_taxons = taxons.select { |t| t.invalid? }
    if invalid_taxons.empty?
      return ::Shared::Success.new(taxons)
    else
      msg = error_msg(invalid_taxons)
      return ::Shared::Failure.new(msg)
    end
  end

  def certify_taxons(taxons)
    return ::Shared::Success.new(taxons) if !need_certify?

    results = taxons.map do |t|
      ::Admin::CertifyTaxon.call(t, @certified_by, @certified_params)
    end

    failure_results = results.select { |r| !r.success? }
    if failure_results.empty?
      ::Shared::Success.new(results.map(&:data))
    else
      msg = error_msg(failure_results)
      ::Shared::Failure.new(msg)
    end
  end

  # 目前只返回一个错误结果
  def error_msg(failure_datas)
    first_invalid_data = failure_datas.first

    msg =
      if first_invalid_data.instance_of? ::Shared::Failure
        first_invalid_data.error
      else
        first_invalid_data.errors.full_messages
      end
  end

  def need_certify?
    (!input_certified_status.blank?) && (input_certified_status != "under_review")
  end

  def taxon_to_create
    @taxon_to_create ||= input_taxon_codes - @handyman.taxon_codes
  end

  private

  def input_taxon_codes
    @taxon_codes
  end

  def input_certified_status
    @input_certified_status ||= @certified_params[:certified_status]
  end
end
