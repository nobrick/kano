class Admin::CertifyTaxon
  def self.call(*args)
    new(*args).call
  end

  def initialize(taxon, certified_by, certified_params = {})
    @taxon = taxon
    @certified_by = certified_by
    @certified_params = certified_params
  end

  def call
    if @taxon.update(certified_info)
      ::Shared::Success.new(@taxon)
    else
      ::Shared::Failure.new(@taxon.errors.full_messages)
    end
  end

  private

  def certified_info
    info = basic_info

    case input_status
    when "success"
      info[:reason_code] = nil
      info[:reason_message] = nil
    when "under_review"
      info[:reason_code] = nil
      info[:reason_message] = nil
      info[:certified_by] = nil
      info[:certified_at] = nil
    end

    info
  end

  def basic_info
    {
      certified_status: input_status,
      reason_code: input_reason_code,
      reason_message: input_reason_message,
      certified_by: @certified_by,
      certified_at: Time.now
    }
  end

  def input_status
    @certified_params[:certified_status]
  end

  def input_reason_code
    @certified_params[:reason_code]
  end

  def input_reason_message
    @certified_params[:reason_message]
  end
end
