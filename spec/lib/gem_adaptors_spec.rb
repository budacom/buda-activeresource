require 'spec_helper'
require 'active_admin_resource/railties/rspec' # Use Resource API Mock
require 'money'
require 'money-rails'
require 'formtastic'
require 'action_view'
require 'enumerize'

describe ActiveAdminResource::GemAdaptors do

  class Elephant < ActiveAdminResource::Base
    enumerize :continent_of_origin, in: [:africa, :asia], default: :asia
    monetize :cost

    schema do
      attribute 'id', :integer
      attribute 'name', :string
      attribute 'cost', :float # money attribute
      attribute 'continent_of_origin', :string # enumerize attribute
    end
  end

  let(:elephant) { Elephant.create(cost: [455_000.5, 'USD'], continent_of_origin: 'africa') }
  let(:homeless_elephant) { Elephant.create(name: 'Bill') }

  # describe 'Enumerize Adaptor' do
  #   describe 'getter' do
  #     context 'with a record with persisted continent' do
  #       it 'gets correct enumerize value' do
  #         expect(elephant.continent_of_origin).to eq('africa')
  #         expect(elephant.attributes[:continent_of_origin]).to eq('africa')
  #         expect(elephant.continent_of_origin.africa?).to be_truthy
  #         expect(elephant.continent_of_origin.class).to eq(Enumerize::Value)
  #       end
  #     end
  #     context 'with a record without continent' do
  #       it 'gets default enumerize value' do
  #         expect(homeless_elephant.continent_of_origin).to eq('asia')
  #         expect(homeless_elephant.attributes[:continent_of_origin]).to eq('asia')
  #         expect(homeless_elephant.continent_of_origin.asia?).to be_truthy
  #         expect(homeless_elephant.continent_of_origin.class).to eq(Enumerize::Value)
  #       end
  #     end
  #   end

  #   describe 'setter' do
  #     before do
  #       homeless_elephant.continent_of_origin = :africa
  #     end
  #     it 'sets correct enumerize value' do
  #       expect(homeless_elephant.continent_of_origin).to eq('africa')
  #       expect(homeless_elephant.attributes[:continent_of_origin]).to eq(:africa)
  #       expect(elephant.continent_of_origin.africa?).to be_truthy
  #     end
  #   end
  # end

  describe 'Money Adaptor' do

    describe 'getter' do
      it 'gets correct money value' do
        expect(elephant.cost).to eq(Money.from_amount(455_000.5, 'USD'))
      end
    end

    describe 'setter' do
      context 'used with Money object' do
        it 'sets correct money value' do
          expect { homeless_elephant.cost = Money.from_amount(150_000, 'USD') }
            .to change { homeless_elephant.cost }
            .from(nil).to(Money.from_amount(150_000, 'USD'))
        end
      end

      context 'used with numeric value' do
        it 'sets money value with default currency' do
          expect { homeless_elephant.cost = 179_800 }
            .to change { homeless_elephant.cost }
            .from(nil).to(Money.from_amount(179_800, 'USD'))
        end
      end
    end
  end
end
