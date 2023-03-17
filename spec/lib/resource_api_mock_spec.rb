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

  let(:super_zoo) { Zoo.new(1) }
  let!(:tall_jimmy) do
    Giraffe.create(name: 'Jimmy', zoo_id: super_zoo.id, height: 4.9, color: 'brown')
  end
  let!(:small_george) do
    Giraffe.create(id: 57, name: 'George', zoo_id: super_zoo.id, height: 3.3, color: 'beige')
  end

  describe 'unfiltered query via #all' do
    it 'finds the created records' do
      expect(Giraffe.all).to eq([tall_jimmy, small_george])
    end
  end

  describe 'filtered query via #where' do
    it 'gets the corresponding records' do
      expect(Giraffe.where(color: 'brown')).to eq([tall_jimmy])
      expect(Giraffe.where(zoo: super_zoo)).to eq([tall_jimmy, small_george])
    end
  end

  describe 'get single record via #find(<id>)' do
    it 'gets the corresponding record' do
      expect(Giraffe.find(57)).to eq(small_george)
    end
  end

  describe '#destroy' do
    before { tall_jimmy.destroy }
    it "doesn't find the record anymore" do
      expect(Giraffe.all).to eq([small_george])
    end
  end

  describe 'update via #save' do
    before do
      small_george.color = 'black'
      small_george.save
    end
    it 'updates record on store' do
      expect(small_george.reload.color).to eq('black')
      expect(Giraffe.where(color: 'black')).to eq([small_george])
    end
  end
end
