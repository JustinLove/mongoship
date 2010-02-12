require File.dirname(__FILE__) + '/spec_helper.rb'
require 'rubygems'
require 'mongo'

# Time to add your specs!
# http://rspec.info/
describe "MongoDB" do

  before :all do
    @db = Mongo::Connection.new.db("mongoship")
    @shipments = @db.collection("shipments")
    @shipments.remove
    @shipments.insert(:date => Time.now,
      :num => 1,
      :shipping_lines => [
        {
          :item_id => 1,
          :qty => 1,
          :price => 10.00
        },
        {
          :item_id => 2,
          :qty => 5,
          :price => 100.00
        },
        {
          :item_id => 3,
          :qty => 2,
          :price => 3.00
        }
      ],
      :package => [
        {
          :type => :crate,
          :tracking_number => "tracking1",
          :pkg_lines => [
            {
              :item_id => 1,
              :qty => 1
            },
            {
              :item_id => 2,
              :qty => 2
            }
          ]
        },
        {
          :type => :box,
          :tracking_number => "tracking2",
          :pkg_lines => [
            {
              :item_id => 2,
              :qty => 3
            },
            {
              :item_id => 3,
              :qty => 2
            }
          ]
        }
      ]).class.should == Mongo::ObjectID
  end
  
  it "retrieves the shipment" do
    @shipments.find_one(:num => 1).class == Mongo::ObjectID
  end

  it "for a shipment number list it's tracking numbers" do
    ship = @shipments.find({"num" => 1}).first
    tracking = ship["package"].map do |package|
      package["tracking_number"]
    end
    tracking.member? "tracking1"
    tracking.member? "tracking2"
  end
  
  it "for a tracking number, find it's shipment" do
    ship = @shipments.find({"package.tracking_number" => "tracking1"}).first
    ship["num"].should == 1
  end
  
  it "for a shipment number, list data for customs declaration" do
    ship = @shipments.find({"num" => 1}).first
    values = {}
    ship["shipping_lines"].each do |line|
      values[line["item_id"]] = line["price"]
    end
    packages = []
    ship["package"].each_with_index do |package,i|
      lines = package["pkg_lines"].map do |line|
        {
          :item_code => line["item_id"],
          :qty => line["qty"],
          :value => line["qty"] * values[line["item_id"]]
        }
      end
      packages << {
        :number => i + 1,
        :items => lines
      }
    end
    packages.first[:number].should == 1
    x = packages.first[:items][1]
    x[:item_code].should == 2
    x[:qty].should == 2
    x[:value].should == 200
  end
end
