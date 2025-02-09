require 'rspec'
require 'mysql2'
require_relative '../tax_calculator'  

RSpec.describe 'process_tax' do
  let(:connection) { double('Mysql2::Client') }
  let(:sale) { { "id" => 1 } }  # Sale ID updated to 1
  let(:vat_rate) { 21 }  # Spanish VAT rate of 21%
  let(:transaction_marker) { 'Spanish VAT' }

  before do
    # Mock the get_total_sales_amount method to return 12.99 for sale_id 1
    allow(self).to receive(:get_total_sales_amount).and_return(12.99)  # sale_amount = 12.99
    allow(self).to receive(:update_sale)  # Mock update_sale to avoid actual database update
  end

  it 'calculates tax correctly and updates sale for Spanish VAT' do
    # Expected values based on sale amount 12.99
    sale_amount = 12.99
    calculated_tax = 2.727900  # Adjusted calculated tax to match your database value
    total_amount = sale_amount + calculated_tax  # 12.99 + 2.727900 = 15.717900

    # Call the process_tax method
    process_tax(connection, sale, vat_rate, transaction_marker)

    # Check if update_sale was called with the correct parameters
    expect(self).to have_received(:update_sale).with(connection, sale["id"], sale_amount, total_amount, calculated_tax, transaction_marker)
  end
end
