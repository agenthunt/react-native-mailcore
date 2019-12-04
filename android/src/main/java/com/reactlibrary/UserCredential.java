package com.reactlibrary;
import com.facebook.react.bridge.ReadableMap;

public class UserCredential {
    private String username;
    private String password;
    private String hostname;
    private Integer port;
    private int authType;


    public UserCredential(ReadableMap obj){
        this.hostname = obj.getString("hostname");
        this.port = obj.getInt("port");
        this.username = obj.getString("username");
        this.password = obj.getString("password");
        this.authType = obj.getInt("authType");
    }

    public String getHostname(){
        return hostname;
    }

    public Integer getPort() {
        return port;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword(){
        return password;
    }

    public int getAuthType() { return authType; }
}