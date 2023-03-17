require 'enumerize'
require_relative '../../lib/buda_activeresource'

describe BudaActiveResource::EnumerizeExtensions do

  class Elephant < ActiveAdminResource::Base
    enumerize :continent_of_origin, in: %i[africa asia], default: :asia
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

  describe 'Enumerize Adaptor' do
    describe 'getter' do
      context 'with a record with persisted continent' do
        it 'gets correct enumerize value' do
          expect(elephant.continent_of_origin).to eq('africa')
          expect(elephant.attributes[:continent_of_origin]).to eq('africa')
          expect(elephant.continent_of_origin.africa?).to be_truthy
          expect(elephant.continent_of_origin.class).to eq(Enumerize::Value)
        end
      end

      context 'with a record without continent' do
        it 'gets default enumerize value' do
          expect(homeless_elephant.continent_of_origin).to eq('asia')
          expect(homeless_elephant.attributes[:continent_of_origin]).to eq('asia')
          expect(homeless_elephant.continent_of_origin.asia?).to be_truthy
          expect(homeless_elephant.continent_of_origin.class).to eq(Enumerize::Value)
        end
      end
    end

    describe 'setter' do
      before do
        homeless_elephant.continent_of_origin = :africa
      end
      it 'sets correct enumerize value' do
        expect(homeless_elephant.continent_of_origin).to eq('africa')
        expect(homeless_elephant.attributes[:continent_of_origin]).to eq(:africa)
        expect(elephant.continent_of_origin.africa?).to be_truthy
      end
    end
  end

end
