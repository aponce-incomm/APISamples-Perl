#! /usr/bin/perl -w
use strict;
use LWP::UserAgent;
use HTTP::Request::Common;
use XML::Simple;
use JSON;
use Data::Dumper;

#Settings
my $url = "";
my $apikey = "";
my $timeout = 0;
my $lang_type = ""; #'xml' or 'json'

#Transaction Info
my $type = 'SALE';
my $card_number = '4111111111111111';
my $card_csc = '123';
my $expiry_date = '1121';
my $amount = '10.00';
my $avs_address = '112 N. Orion Court';
my $avs_zip = '20210';
my $purchase_order = '10';
my $invoice = '100';
my $email = 'email@tsg.com';
my $customer_id = '25';
my $order_number = '1000';
my $client_ip = '';
my $description = 'Cel Phone';
my $comments = 'Electronic Product';
my $billing_first_name = 'Joe';
my $billing_last_name = 'Smith';
my $billing_company = 'Company Inc.';
my $billing_address1 = 'Street 1';
my $billing_address2 = 'Street 2';
my $billing_city = 'Jersey City';
my $billing_state = 'NJ';
my $billing_zip = '07097';
my $billing_country = 'USA';
my $billing_phone = '123456789';
my $shipping_first_name = 'Joe';
my $shipping_last_name = 'Smith';
my $shipping_company = 'Company 2 Inc.';
my $shipping_address1 = 'Street 1 2';
my $shipping_address2 = 'Street 2 2';
my $shipping_city = 'Colorado City';
my $shipping_state = 'TX';
my $shipping_zip = '79512';
my $shipping_country = 'USA';
my $shipping_phone = '123456789';

#build a XML formatted transaction 
sub buildXML {         
    my $xml = "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<transaction>
    <api_key>$apikey</api_key>
    <type>$type</type>
    <card>$card_number</card>
    <csc>$card_csc</csc>
    <exp_date>$expiry_date</exp_date>
    <amount>$amount</amount>
    <avs_address>$avs_address</avs_address>
    <avs_zip>$avs_zip</avs_zip>
    <email>$email</email>
    <customer_id>$customer_id</customer_id>
    <order_number>$order_number</order_number>
    <purchase_order>$purchase_order</purchase_order>
    <invoice>$invoice</invoice>
    <client_ip>$client_ip</client_ip>
    <description>$description</description>
    <comments>$comments</comments>
    <billing>
        <first_name>$billing_first_name</first_name>
        <last_name>$billing_last_name</last_name>
        <company>$billing_company</company>
        <street>$billing_address1</street>
        <street2>$billing_address2</street2>
        <city>$billing_city</city>
        <state>$billing_state</state>
        <zip>$billing_zip</zip>
        <country>$billing_country</country>
        <phone>$billing_phone</phone>
    </billing>
    <shipping>
        <first_name>$shipping_first_name</first_name>
        <last_name>$shipping_last_name</last_name>
        <company>$shipping_company</company>
        <street>$shipping_address1</street>
        <street2>$shipping_address2</street2>
        <city>$shipping_city</city>
        <state>$shipping_state</state>
        <zip>$shipping_zip</zip>
        <country>$shipping_country</country>
        <phone>$shipping_phone</phone>
    </shipping>
</transaction>";
      return($xml);  
   }

#build a JSON formatted transaction 
sub buildJSON {         
    my $json = "{
	\"api_key\": \"".$apikey."\",
    \"type\": \"". $type."\",
    \"card\": \"". $card_number."\",
    \"csc\": \"". $card_csc."\",
    \"exp_date\": \"". $expiry_date."\",
    \"amount\": \"". $amount."\",
    \"email\": \"". $email."\",
    \"customer_id\": \"". $customer_id."\",
	\"order_number\": \"".$order_number."\",
	\"purchase_order\": \"". $purchase_order."\",
	\"invoice\": \"". $invoice."\",              
    \"client_ip\": \"". $client_ip."\",
    \"description\": \"". $description."\",
	\"comments\": \"".$comments."\",
    \"billing\": {
      \"first_name\": \"". $billing_first_name."\",
      \"last_name\": \"". $billing_last_name."\",
      \"company\": \"". $billing_company."\",
      \"street\": \"". $billing_address1."\",
	  \"street2\": \"". $billing_address2."\",
      \"city\": \"". $billing_city."\",
      \"state\": \"". $billing_state."\",
      \"zip\": \"". $billing_zip."\",
      \"country\": \"". $billing_country."\",
      \"phone\": \"". $billing_phone."\"
    },
    \"shipping\": {
      \"first_name\": \"". $shipping_first_name."\",
      \"last_name\": \"". $shipping_last_name."\",
      \"company\": \"". $shipping_company."\",
      \"street\": \"". $shipping_address1."\",
	  \"street2\": \"". $shipping_address2."\",
      \"city\": \"". $shipping_city."\",
      \"state\": \"". $shipping_state."\",
      \"zip\": \"". $shipping_zip."\",
      \"country\": \"". $shipping_country."\",
      \"phone\": \"". $shipping_phone."\"
    }
}";
      return($json);  
   }
 

 
#Transaction xml model
my $transaction = buildXML(); #xml by default
if ($lang_type eq "json") {   #if JSON is chosen, build a JSON formatted transaction       
    $transaction = buildJSON();
} 

print "-----------------------------------------------------\n";
print "REQUEST TO URL: $url\n";
print "POST DATA: $transaction\n";

#Http Request
my $userAgent = LWP::UserAgent->new(agent => 'perl post',timeout => $timeout, keep_alive => 1);
my $response = $userAgent->request(POST $url,
Content_Type => 'application/'.$lang_type,
Content => $transaction);

#parse response
if($response->is_success){ #http status 200
    print "-----------------------------------------------------\n";
    print "RESPONSE DATA: \n".$response->content()."\n";
    
    my $transaction_response;
    if ($lang_type eq "json") {   # if the chosen language was JSON, then the server will respond back with JSON     
        $transaction_response = decode_json($response->content()); #parse json
    }else{ # if the chosen language was XML, then the server will respond back with XML
        my $xml = new XML::Simple; #parse xml
        $transaction_response = $xml->XMLin($response->content());
    }    
    #parse response according to its content
    if($transaction_response->{result_code} and $transaction_response->{result_code} eq "0000"){
        print "-----------------------------------------------------\n";
        print "TRANSACTION APPROVED: " . $transaction_response->{authorization_code};
    }
    else{
        my $code = "";
        $code = $transaction_response->{error_code} if($transaction_response->{error_code});
        $code = $transaction_response->{result_code} if($transaction_response->{result_code});
        print "-----------------------------------------------------\n";
        print "TRANSACTION ERROR: Code=" . $code . " Message=" . $transaction_response->{display_message};
    }
}
else{
    print "-----------------------------------------------------\n";
    print "Unexpected error: " . $response->error_as_HTML;
}
