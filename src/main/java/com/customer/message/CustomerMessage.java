package com.customer.message;

public class CustomerMessage {

	private int CustomerMessageId;
	private String CustomerMessage;

	public CustomerMessage() {

	}

	public CustomerMessage(int customerMessageId, String customerMessage) {
		super();
		CustomerMessageId = customerMessageId;
		CustomerMessage = customerMessage;
	}

	public int getCustomerMessageId() {
		return CustomerMessageId;
	}

	public void setCustomerMessageId(int customerMessageId) {
		CustomerMessageId = customerMessageId;
	}

	public String getCustomerMessage() {
		return CustomerMessage;
	}

	public void setCustomerMessage(String customerMessage) {
		CustomerMessage = customerMessage;
	}

	@Override
	public String toString() {
		return "CustomerMessage [CustomerMessageId=" + CustomerMessageId + ", CustomerMessage=" + CustomerMessage + "]";
	}

}
