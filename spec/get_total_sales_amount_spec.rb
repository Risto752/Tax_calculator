require 'rspec'
require 'mysql2'
require_relative '../tax_calculator'  

RSpec.describe 'Tax Calculator' do
  let(:connection) { double('Mysql2::Client') }
  let(:sale_id) { 3 }
  let(:mock_sales_data) do
    [
      { 'quantity' => 5, 'price_in_euros' => 6.99 }
    ]
  end

  describe '#get_total_sales_amount' do
    it 'calculates the total sales amount correctly' do
      # Prepare the mock result for the query
      allow(connection).to receive(:prepare).and_return(double('Mysql2::Statement'))
      allow(connection).to receive_message_chain(:prepare, :execute).and_return(mock_sales_data)

      # Call the method
      total_amount = get_total_sales_amount(connection, sale_id)

      # Calculate the expected total amount manually (5 * 6.99 = 34.95)
      expected_total_amount = 34.95

      # Expect the total amount to match the expected result
      expect(total_amount).to eq(expected_total_amount)
    end
  end
end
