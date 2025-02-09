require 'rspec'
require 'mysql2'
require_relative '../tax_calculator.rb'

RSpec.describe 'Tax Calculator' do
    let(:connection) { double('Mysql2::Client') }
  
    describe '#get_product_type' do
      it 'returns the correct product type for a given sale ID' do
        # Mock the sale IDs and their corresponding product types
        sale_id_1 = 1
        sale_id_2 = 2
        sale_id_3 = 3
  
        product_type_1 = { 'product_type' => 'good' }
        product_type_2 = { 'product_type' => 'digital' }
        product_type_3 = { 'product_type' => 'onsite' }
  
        # Mock the query results for each sale_id
        allow(connection).to receive(:prepare).with(any_args).and_return(double(execute: [product_type_1]))
        result_1 = get_product_type(connection, sale_id_1)
        expect(result_1['product_type']).to eq('good')
  
        allow(connection).to receive(:prepare).with(any_args).and_return(double(execute: [product_type_2]))
        result_2 = get_product_type(connection, sale_id_2)
        expect(result_2['product_type']).to eq('digital')
  
        allow(connection).to receive(:prepare).with(any_args).and_return(double(execute: [product_type_3]))
        result_3 = get_product_type(connection, sale_id_3)
        expect(result_3['product_type']).to eq('onsite')
      end
    end
  end