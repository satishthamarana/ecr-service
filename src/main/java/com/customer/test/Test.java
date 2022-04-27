package com.customer.test;

import com.customer.message.CustomerMessage;

public class Test {

	public static void main(String[] args) {

		CustomerMessage customer = new CustomerMessage();

		customer.setCustomerMessageId(7923);
		customer.setCustomerMessage("Hello Wolrd");

		
		System.out.println("the message is"+" "+customer.getCustomerMessage()+" and the message id is "+ customer.getCustomerMessageId());
	}

}
