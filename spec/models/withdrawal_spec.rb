require 'rails_helper'
require 'support/payment'
require 'support/timecop'

RSpec.describe Withdrawal, type: :model do
  let(:withdrawal) { Withdrawal.new(attributes) }
  let(:handyman) { create :handyman }
  let(:authorizer) { create :admin }
  let(:attributes) { attributes_for :withdrawal }
  let(:date) { now.last_month.change(day: permitted_days.sample) }
  let(:forbidden_date) { 1.day.until date }
  let(:next_date) { dates.find { |d| d - date >= 14.days } }
  let(:permitted_days) { [ 7, 14, 21, 28 ] }
  let(:now) { Time.now }
  let(:dates) do
    m_days = [ now, now.last_month, now.next_month ]
    permitted_days.flat_map { |n| m_days.map { |d| d.change(day: n) } }.sort
  end

  describe 'audit_state' do
    it 'is unaudited by default' do
      expect(Withdrawal.new.audit_state).to eq 'unaudited'
    end
  end

  describe '#request' do
    before { withdrawal.handyman = handyman }

    context 'When requests already exist' do
      before do
        on(unfrozen date) { create_paid_orders_for handyman, 1 }
        on(date) { withdrawal.request && withdrawal.save! }
        on(unfrozen next_date) { create_paid_orders_for handyman, 1 }
      end
      let(:another_handyman) { create :handyman }
      let(:new_withdrawal) { Withdrawal.new }

      it 'fails to request if already does within frozen days' do
        expect(withdrawal.reload.requested?).to eq true
        on(next_date) do
          new_withdrawal.handyman = handyman
          new_withdrawal.assign_attributes(attributes)
          expect(new_withdrawal.request).to eq true
          expect(new_withdrawal.save).to eq false
          expect(new_withdrawal.errors.messages.keys).to eq [ :base ]
          expect(new_withdrawal.errors.messages[:base].count).to eq 1
        end
      end

      it 'ensures uniqueness of requested withdrawal for race condition' do
        on(next_date) do
          new_withdrawal.handyman = handyman
          new_withdrawal.assign_attributes(attributes)
          new_withdrawal.request
          expect {
            new_withdrawal.save(validate: false)
          }.to raise_error  ActiveRecord::RecordNotUnique, /index_requested_wi/
        end
      end

      it 'does not affect legal withdrawal for other handymen' do
        on(unfrozen next_date) { create_paid_orders_for another_handyman, 1 }
        new_withdrawal.handyman = another_handyman
        new_withdrawal.assign_attributes(attributes)
        on(next_date) { new_withdrawal.request && new_withdrawal.save! }
        expect(new_withdrawal.reload.requested?).to eq true
      end
    end

    context 'When no unfrozen record exists' do
      shared_examples_for 'unfrozen_record validation failure' do
        it 'fails validation'  do
          on(date) do
            expect(withdrawal.request).to eq true
            expect(withdrawal.save).to eq false
          end
          expect(withdrawal.errors.messages.keys).to eq [ :unfrozen_record ]
        end
      end

      context 'With records created before' do
        before { on(13.days.until date) { create_paid_orders_for handyman, 1 } }

        it_behaves_like 'unfrozen_record validation failure'
      end

      context 'With no records ever created' do
        it_behaves_like 'unfrozen_record validation failure'
      end
    end

    context 'When not on permitted dates' do
      before { on(unfrozen forbidden_date) { create_paid_orders_for handyman, 1 } }

      it 'fails validation' do
        on(forbidden_date) do
          expect(withdrawal.request).to eq true
          expect(withdrawal.save).to eq false
          expect(withdrawal.errors.messages.keys).to eq [ :base ]
        end
      end
    end

    context 'When request is valid' do
      before { on(unfrozen date) { create_paid_orders_for handyman, 1 } }

      it 'persists' do
        on(date) do
          expect(withdrawal.request).to eq true
          withdrawal.save!
        end
      end

      it 'sets unfrozen_record' do
        on(date) { withdrawal.request && withdrawal.save! }
        unfrozen_record = on(unfrozen date) { handyman.last_balance_record }
        expect(withdrawal.unfrozen_record).to eq unfrozen_record
      end

      it 'sets total' do
        on(date) { withdrawal.request && withdrawal.save! }
        online_income_total = handyman.unfrozen_balance_record.online_income_total
        withdrawal_total = handyman.last_balance_record.withdrawal_total
        expect(withdrawal.total).to eq online_income_total - withdrawal_total
      end
    end
  end

  shared_examples_for 'authorizer presence' do
    after do
      expect(withdrawal.send method).to eq true
      expect { withdrawal.save }
        .to raise_error ActiveModel::StrictValidationFailed
    end

    it 'ensures that authorizer must be present' do
      withdrawal.authorizer = nil
    end

    it 'ensures that authorizer must be admin' do
      withdrawal.authorizer = create :user
    end
  end

  describe '#transfer' do
    before do
      withdrawal.handyman = handyman
      on(unfrozen date) { create_paid_orders_for handyman, 2 }
      on(date) { withdrawal.request && withdrawal.save! }
    end

    context 'When transfer is valid' do
      before { withdrawal.authorizer = authorizer }

      it 'transitions into transferred state' do
        on(2.days.since date) do
          expect(withdrawal.transfer).to eq true
          expect(withdrawal.save).to eq true
        end
        expect(withdrawal.reload.transferred?).to eq true
      end

      it 'creates balance record' do
        on(date) do
          expect { withdrawal.transfer && withdrawal.save! }
            .to change(BalanceRecord, :count).by 1
          expect(BalanceRecord.first.event).to eq withdrawal
        end
      end
    end

    describe 'authorizer' do
      let(:method) { :transfer }
      it_behaves_like 'authorizer presence'
    end
  end

  describe '#decline' do
    before do
      withdrawal.handyman = handyman
      withdrawal.authorizer = authorizer
      on(unfrozen date) { create_paid_orders_for handyman, 2 }
      on(date) { withdrawal.request && withdrawal.save! }
    end

    context 'On valid decline' do
      it 'transitions into declined state' do
        on(2.days.since date) do
          withdrawal.reason_message = 'content'
          expect(withdrawal.decline).to eq true
          expect(withdrawal.save).to eq true
        end
        expect(withdrawal.reload.declined?).to eq true
      end
    end

    context 'When reason_message is blank' do
      it 'fails validate' do
        withdrawal.reason_message = ''
        expect(withdrawal.decline).to eq true
        expect(withdrawal.save).to eq false
        expect(withdrawal.errors.messages.keys).to eq [ :reason_message ]
      end
    end

    describe 'authorizer' do
      let(:method) { :decline }
      it_behaves_like 'authorizer presence'
    end
  end

  describe '.next_permitted_requesting_date' do
    it 'returns next permitted date for withdrawal request' do
      expect(Withdrawal.next_permitted_requesting_date on(1, 7).to_date)
        .to eq on(1, 14).to_date
      expect(Withdrawal.next_permitted_requesting_date on(1, 28))
        .to eq on(2, 7).to_date
      expect(Withdrawal.next_permitted_requesting_date on(1, 31))
        .to eq on(2, 7).to_date
    end
  end

  describe 'FactoryGirl methods' do
    before { on(unfrozen date) { create_paid_orders_for handyman, 1 } }

    it 'creates requested withdrawal' do
      withdrawal = on(date) do
        create :requested_withdrawal, handyman: handyman
      end
      expect(withdrawal).to be_persisted
      expect(withdrawal.requested?).to eq true
    end

    it 'creates transferred withdrawal' do
      withdrawal = on(date) do
        create :transferred_withdrawal, handyman: handyman
      end
      expect(withdrawal).to be_persisted
      expect(withdrawal.transferred?).to eq true
    end

    it 'creates declined withdrawal' do
      withdrawal = on(date) do
        create :declined_withdrawal, handyman: handyman
      end
      expect(withdrawal).to be_persisted
      expect(withdrawal.declined?).to eq true
    end
  end

  def unfrozen(date)
    14.days.until(date)
  end
end
