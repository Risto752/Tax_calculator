require 'rspec'
require 'mysql2'
require_relative '../tax_calculator'

RSpec.describe 'Tax Calculator' do
  let(:connection) { double('Mysql2::Client') }

  describe '#get_buyer_country_and_type' do
    it 'returns the correct buyer information for a given buyer ID' do
      # Mock buyer data for different buyer IDs
      buyer_id_1 = 1 # Individual in Spain
      buyer_id_2 = 2 # Company in the EU
      buyer_id_3 = 3 # Individual outside the EU

      buyer_1 = { 'country_name' => 'Spain', 'vat_applicable' => 'spain', 'vat_rate' => 21, 'is_company' => 0 }
      buyer_2 = { 'country_name' => 'Germany', 'vat_applicable' => 'eu', 'vat_rate' => 19, 'is_company' => 1 }
      buyer_3 = { 'country_name' => 'USA', 'vat_applicable' => 'non_eu', 'vat_rate' => 7.25, 'is_company' => 0 }

      # Mock the query results for each buyer_id
      allow(connection).to receive(:prepare).with(any_args).and_return(double(execute: [buyer_1]))
      result_1 = get_buyer_country_and_type(connection, buyer_id_1)
      expect(result_1['country_name']).to eq('Spain')
      expect(result_1['vat_applicable']).to eq('spain')
      expect(result_1['vat_rate']).to eq(21)
      expect(result_1['is_company']).to eq(0)

      allow(connection).to receive(:prepare).with(any_args).and_return(double(execute: [buyer_2]))
      result_2 = get_buyer_country_and_type(connection, buyer_id_2)
      expect(result_2['country_name']).to eq('Germany')
      expect(result_2['vat_applicable']).to eq('eu')
      expect(result_2['vat_rate']).to eq(19)
      expect(result_2['is_company']).to eq(1)

      allow(connection).to receive(:prepare).with(any_args).and_return(double(execute: [buyer_3]))
      result_3 = get_buyer_country_and_type(connection, buyer_id_3)
      expect(result_3['country_name']).to eq('USA')
      expect(result_3['vat_applicable']).to eq('non_eu')
      expect(result_3['vat_rate']).to eq(7.25)
      expect(result_3['is_company']).to eq(0)
    end
  end
end
