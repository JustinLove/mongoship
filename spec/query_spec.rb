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
end
