require 'rspec'
require 'mysql2'
require_relative '../tax_calculator.rb'

RSpec.describe 'mark_transaction_when_no_tax' do
    let(:connection) { double('Mysql2::Client') }
    let(:sale) { { "id" => 3 } }  # Sale ID 3
    let(:transaction_marker) { 'export' }  # No VAT applied, for example
  
    before do
      # Mock the get_total_sales_amount method to return 34.95 for sale_id 3
      allow(self).to receive(:get_total_sales_amount).and_return(34.95)  # sale_amount = 34.95
      allow(self).to receive(:update_sale)  # Mock update_sale to avoid actual database update
    end
  
    it 'marks transaction correctly without tax' do
      sale_amount = 34.95
      total_amount = sale_amount  # No tax, so total amount = sale amount
      calculated_tax = 0  # No tax applied
  
      # Call the mark_transaction_when_no_tax method
      mark_transaction_when_no_tax(connection, sale, transaction_marker)
  
      # Check if update_sale was called with the correct parameters
      expect(self).to have_received(:update_sale).with(connection, sale["id"], sale_amount, total_amount, calculated_tax, transaction_marker)
    end
  end