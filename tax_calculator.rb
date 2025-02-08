require 'mysql2'

# Establish a database connection
def get_database_connection
  Mysql2::Client.new(
    host: 'localhost',     # Host where MySQL is running
    username: 'root',      # MySQL username
    password: '',          # MySQL password
    database: 'tax_calculator' # Database name
  )
end

def get_product_type(connection, sale_id)
    query = <<-SQL
      SELECT pt.name AS product_type
      FROM sold_items si
      JOIN products p ON si.product_id = p.id
      JOIN product_types pt ON p.product_type_id = pt.id
      WHERE si.sale_id = #{sale_id}
    SQL
    result = connection.query(query).first
    result # Returns the product type name
  end

  def get_buyer_country_and_type(connection, buyer_id)
    query = <<-SQL
      SELECT c.name AS country_name, c.vat_applicable, c.vat_rate, b.is_company
      FROM buyers b
      JOIN countries c ON b.country_id = c.id
      WHERE b.id = #{buyer_id}
    SQL
    result = connection.query(query).first
    result # Returns the country name, VAT applicable status, VAT rate, and buyer type
  end

  # Get sale amount from sold items and calculate total sale
def get_total_sales_amount(connection, sale_id)
    
    query = <<-SQL
      SELECT si.quantity, p.price_in_euros
      FROM sold_items si
      JOIN products p ON si.product_id = p.id
      WHERE si.sale_id = #{sale_id}
    SQL
    sales = connection.query(query)
  
    total_amount = 0.0
    sales.each do |item|
      total_amount += item['quantity'].to_f * item['price_in_euros'].to_f
    end
  
    total_amount
  end

  def update_sale(connection, sale_id, subtotal, total_amount, calculated_tax, vat_status)
    query = <<-SQL
      UPDATE sales
      SET subtotal = #{subtotal}, total_amount = #{total_amount}, calculated_tax = #{calculated_tax}, vat_status = '#{vat_status}', processed = true
      WHERE id = #{sale_id}
    SQL
    connection.query(query)
  end
  
  def calculate_spanish_tax(connection, sale, vat_rate)

    sale_amount = get_total_sales_amount(connection, sale["id"])
    calculated_tax = sale_amount * (vat_rate.to_f / 100)
    vat_status = "Spanish VAT"
    total_amount = sale_amount + calculated_tax

    update_sale(connection, sale["id"],sale_amount, total_amount, calculated_tax, vat_status)

  end
  
def calculate_eu_tax(connection, sale, vat_rate, is_company)

    if !is_company
        sale_amount = get_total_sales_amount(connection, sale["id"])
        calculated_tax = sale_amount * (vat_rate.to_f / 100)
        vat_status = "Local VAT"
        total_amount = sale_amount + calculated_tax

    update_sale(connection, sale["id"],sale_amount, total_amount, calculated_tax, vat_status)
    else
        sale_amount = get_total_sales_amount(connection, sale["id"])
        vat_status = "reverse charge"
        total_amount = sale_amount
        calculated_tax = 0
        update_sale(connection, sale["id"],sale_amount, total_amount, calculated_tax, vat_status)

  end

end

def calculate_local_tax(connection, sale,vat_rate)

    sale_amount = get_total_sales_amount(connection, sale["id"])
    calculated_tax = sale_amount * (vat_rate.to_f / 100)
    vat_status = "Local tax"
    total_amount = sale_amount + calculated_tax

end

def mark_transaction_when_no_tax(connection, sale, marker)

    sale_amount = get_total_sales_amount(connection, sale["id"])
    vat_status = marker
    total_amount = sale_amount
    calculated_tax = 0
    update_sale(connection, sale["id"],sale_amount, total_amount, calculated_tax, vat_status)


end



def calculate_tax
 
  connection = get_database_connection

  begin
   
    sales = connection.query("SELECT * FROM sales")

  
    sales.each do |sale|

        # Skip calculation if the sale has already been processed (processed = true)
      next if sale['processed'] == 1
    
     
      product_type = get_product_type(connection, sale['id'])
      buyer_info = get_buyer_country_and_type(connection,sale["buyer_id"])

      is_company = buyer_info["is_company"]
      

      if is_company == 1
        is_company = true
      else
        is_company = false
      end
      vat_applicable = buyer_info["vat_applicable"]
      vat_rate = buyer_info["vat_rate"]

       

      case product_type["product_type"]

      when "good"
      
        case vat_applicable

        when "spain"
           
            calculate_spanish_tax(connection,sale,vat_rate)
    
        when "eu"

            calculate_eu_tax(connection,sale,vat_rate,is_company)
           
        when "non_eu"

            mark_transaction_when_no_tax(connection,sale,"export")
           
        end
        
      when "digital"
       
        case vat_applicable

        when "spain"
           
            calculate_spanish_tax(connection,sale,vat_rate)

        when "eu"


        calculate_eu_tax(connection,sale,vat_rate,is_company)
        
          
        when "non_eu"
           
            mark_transaction_when_no_tax(connection, sale, "no tax applied")

        end
        
      when "onsite"
      
        case vat_applicable

        when "spain"
      
            calculate_spanish_tax(connection,sale,vat_rate)

        when "eu"
           
            calculate_local_tax(connection,sale,vat_rate)

        when "non_eu"
           
            calculate_local_tax(connection,sale,vat_rate)

        end
        
      else
        puts "Unknown product type: #{product_type['product_type']}"

      end

     
   
    end
  rescue Mysql2::Error => e
    puts "Error: #{e.message}"
  ensure
    connection.close if connection
  end
end

# Run the tax calculation function
calculate_tax
