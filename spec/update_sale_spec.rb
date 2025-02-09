require 'rspec'
require 'mysql2'
require_relative '../tax_calculator'  

RSpec.describe 'Tax Calculator' do
  let(:connection) { double('Mysql2::Client') }
  
  describe '#update_sale' do
    let(:sale_id) { 123 }
    let(:subtotal) { 100.0 }
    let(:total_amount) { 120.0 }
    let(:calculated_tax) { 20.0 }
    let(:vat_status) { 'Spanish VAT' }

    it 'updates the sale in the database' do
      # Prepare the mock for the statement execution
      statement = double('Mysql2::Statement')
      allow(connection).to receive(:prepare).and_return(statement)
      allow(statement).to receive(:execute)

  
      update_sale(connection, sale_id, subtotal, total_amount, calculated_tax, vat_status)

      # Expect the statement to be executed with the correct parameters
      expect(statement).to have_received(:execute).with(subtotal, total_amount, calculated_tax, vat_status, true, sale_id)
    end
  end
end
