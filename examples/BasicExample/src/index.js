import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  Button
} from 'react-native';
import MailCore from 'react-native-mailcore';

export default class BasicExample extends Component {
  sendMail = () => MailCore.sendMail({
    hostname: 'smtp.gmail.com',
    port: 465,
    username: '<gmail id>',
    password: '<password>',
    from: {
      addressWithDisplayName: 'From Label',
      mailbox: '<from email>'
    },
    to: {
      addressWithDisplayName: 'To Label',
      mailbox: '<to email>'
    },
    subject: 'Testing RN MailCore' + new Date(),
    htmlBody: `<h1> How is it going </h1>
              <p> Test message </p>
            `
  }).then((result) => {
    alert(result.status);
  }).catch((error) => {
    alert(error);
  })
  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to React Native MailCore!
        </Text>
        <Button title="Send Mail" onPress={this.sendMail}
        />
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('BasicExample', () => BasicExample);
