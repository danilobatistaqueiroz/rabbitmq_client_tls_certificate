import java.io.*;
import java.security.*;

import com.rabbitmq.client.*;

public class WithoutValidation {

    public static void main(String[] args) throws Exception {
        ConnectionFactory factory = new ConnectionFactory();
        factory.setHost("172.18.255.200");
        factory.setPort(5671);

        factory.useSslProtocol();
        // Tells the library to setup the default Key and Trust managers for you
        // which do not do any form of remote server trust verification

        Connection conn = factory.newConnection();
        Channel channel = conn.createChannel();

        // non-durable, exclusive, auto-delete queue
        channel.queueDeclare("rabbitmq-java-test", false, true, true, null);
        channel.basicPublish("", "rabbitmq-java-test", null, "Hello, World".getBytes());

        GetResponse chResponse = channel.basicGet("rabbitmq-java-test", false);
        if (chResponse == null) {
            System.out.println("No message retrieved");
        } else {
            byte[] body = chResponse.getBody();
            System.out.println("Received: " + new String(body));
        }

        channel.close();
        conn.close();
    }
}