require 'spec_helper'
require 'active_admin_resource/railties/rspec' # Use Resource API Mock

describe ActiveAdminResource::ResourceApiMock do
  class Zoo
    attr_accessor :id

    def initialize(id)
      self.id = id
    end
  end

  class Giraffe < ActiveAdminResource::Base
    belongs_to :zoo

    schema do
      attribute 'id', :integer
      attribute 'name', :string
      attribute 'zoo_id', :integer
      attribute 'height', :float
      attribute 'color', :string
      attribute 'created_at', :datetime
    end
  end

  def record_ids(records)
    records.map(&:id)
  end

  let(:super_zoo) { Zoo.new(1) }
  let!(:tall_jimmy) do
    Giraffe.create(name: 'Jimmy', zoo_id: super_zoo.id, height: 4.9, color: 'brown')
  end
  let!(:small_george) do
    Giraffe.create(id: 57, name: 'George', zoo_id: super_zoo.id, height: 3.3, color: 'beige')
  end

  describe 'unfiltered query via #all' do
    it 'finds the created records' do
      expect(record_ids(Giraffe.all)).to eq([tall_jimmy.id, small_george.id])
    end
  end

  describe 'filtered query via #where' do
    it 'gets the corresponding records' do
      expect(record_ids(Giraffe.where(color: 'brown'))).to eq([tall_jimmy.id])
      expect(record_ids(Giraffe.where(zoo: super_zoo))).to eq([tall_jimmy.id, small_george.id])
    end
  end

  describe 'get single record via #find(<id>)' do
    it 'gets the corresponding record' do
      expect(Giraffe.find(57).id).to eq(small_george.id)
    end
  end

  describe '#destroy' do
    before { tall_jimmy.destroy }

    it "doesn't find the record anymore" do
      expect(record_ids(Giraffe.all)).to eq([small_george.id])
    end
  end

  describe 'update via #save' do
    before do
      small_george.color = 'black'
      small_george.save
    end

    it 'updates record on store' do
      expect(small_george.reload.color).to eq('black')
      results = Giraffe.where(color: 'black')
      expect(results.size).to eq(1)
      expect(results.first.id).to eq(small_george.id)
      expect(results.first.color).to eq('black')
    end
  end
end
