#!/usr/bin/env ruby
# encoding: UTF-8
#
#  This file implement a Ruby Client for Net Oxygen's SMS gateway.
#
#  @version
#    0.1.0 (19.05.2014)
#
#  @author
#    Alexandre Perrin <alexandre.perrin@netoxygen.ch>
#
#
#  The MIT License (MIT)
#
#  Copyright (c) 2013-2014 Net Oxygen <info@netoxygen.ch>
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to
#  deal in the Software without restriction, including without limitation the
#  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
#  sell copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
#  IN THE SOFTWARE.
#
require 'xmlrpc/client'

# Net Oxygen's main module
module NetOxygen

  # SMS namespace
  module SMS

    # The Client class, using the XML-RPC API.
    class Client
      # the server host
      XMLRPC_API_URI = 'https://sms.netoxygen.ch/api2/'

     # Create a new Client.
     #
     # This constructor require a user and password couple used as credential
     # for the API.
     #
     # @param user (required)
     #   The user user for authentication (string)
     #
     # @param password (required)
     #   The password user for authentication (string)
     #
      def initialize(user, password)
        @user     = user
        @password = password
        @debug    = false
        @handle   = XMLRPC::Client.new_from_uri(XMLRPC_API_URI)
        def @handle.set_debug flag
          @http.set_debug_output(flag ? $stderr : nil);
        end
      end

     # Test if this client has debug enabled.
     #
     # @return
     #   true if debug is enabled, false otherwise.
      def debug
        @debug
      end

      # Set this client in debug mode.
      def enable_debug
        @handle.set_debug(@debug = true)
        self
      end

      # Disable debug mode
      def disable_debug
        @handle.set_debug(@debug = false)
        self
      end

      # Test credentials.
      #
      # This method can be used to test the API credential (user and password).
      # It will try to authenticate and return the result.
      #
      # @return
      #   True when the authentication was a success, false otherwise.
      #
      # If a connection or protocol error arise, an Error is raised.
      #
      def auth
        @handle.call('auth', @user, @password)
      end

      # This method is used to send a SMS to one or more destination(s).
      #
      # All parameters are expected to be encoded in either UTF-8, ASCII
      # (compatible with UTF-8) or ISO-8859-15 (will be converted into UTF-8).
      #
      # @param to (required)
      #   The destination number(s). If you want to send the message to only one
      #   destination you can pass directly a string, otherwise use an Array of
      #   string to define multiple destination numbers.
      #
      # @param message (required)
      #   The message to send (string).
      #
      # @param from (optional, default: '')
      #   This string is displayed as the 'sender' when a SMS a recieved. If
      #   $from is empty or the user is not able to force the 'sender' field,
      #   the default (configured through the account) is used. If no default is
      #   configured then "textobox.ch" is used.
      #
      # @param date (optional, default: '')
      #   When the message should be sent (based on the Europe/Zurich timezone).
      #   If this parameter is either empty, in the past or invalid the message
      #   is sent immediately. The default is to send immediately. The expected
      #   format is the following:
      #   "2013-04-12 02:45:02"
      #
      # @param type (optional, default: 'text')
      #   Either "text" or "flash". "flash" SMS are usually displayed without
      #   needing to be opened but are not saved.
      #
      # @return
      #   An Array of responses, containing one element for each SMS requested.
      #   The returned Array elements are Array with the following keys:
      #
      #   0: the destination number
      #   1: the status code for this SMS
      #   2: a unique SMS-ID that can be used. see get_status().
      #
      # If a connection or protocol error arise, an Error is raised.
      #
      def send_message(to, message, from='', date='', type='text')
        @handle.call('send_message', @user, @password, [*to],
          message.encode('utf-8'), date, type.encode('utf-8'))
      end

      # Cancel a SMS.
      #
      # @param $id (required)
      #   A SMS-ID (string), see send_message(). You can get the
      #   status of several SMS by passing an Array of SMS-ID.
      #
      # @return
      #   An Array of responses, containing one element for each SMS-ID
      #   requested. The returned Array elements are Array with the following
      #   keys:
      #
      #   0: the provided SMS-ID
      #   1: TRUE if the cancel was a success, FALSE otherwise.
      #
      # If a connection or protocol error arise, an Error is raised.
      #
      def cancel_message id
        @handle.call('cancel_message', @user, @password, [*id])
      end

      # Get a SMS's status.
      #
      # This method can be used to test a SMS status (if it has been
      # successfully sent, still in the SMS queue, etc.).
      #
      # @param id (required)
      #   A SMS-ID (string), see send_message(). You can get the
      #   status of several SMS by passing an Array of SMS-ID.
      #
      # @return
      #   An Array of responses, containing one element for each SMS-ID given as
      #   parameter. The returned Array elements are Array with the following
      #   keys:
      #   0: the SMS-ID
      #   1: Hash as following:
      #     - from: the 'from' string given. see send_message().
      #     - to: the destination number of this SMS. see send_message().
      #     - length: the message's length.
      #     - sent_date: The date at the time of sending. see send_message().
      #     - sent_status: The status at the time of sending. see send_message().
      #     - sent_status_text: A descriptive text of the sent_status field (in
      #         english).
      #     - last_date: The date of the last notification.
      #     - last_status: The status of at the last notification time.
      #     - last_status_text: A descriptive text of the last_status field (in
      #         english).
      #
      # If a connection or protocol error arise, an Error is raised.
      #
      def get_status id
        @handle.call('get_status', @user, @password, [*id])
      end

      # Get the total credit for the account.
      #
      # @return
      #   An integer value. Note that if your account type allow to go bellow
      #   zero credits count, the returned value can be negative.
      #
      # If a connection or protocol error arise, an Error is raised.
      #
      def get_credits
        @handle.call('get_credits', @user, @password)
      end

      # Get your account type.
      #
      # @return
      #   A description string of your account type like 'free' or 'regular'.
      #
      # If a connection or protocol error arise, an Error is raised.
      #
      def account_status
        @handle.call('get_credits', @user, @password)
      end

      # Get your account's group id.
      #
      # This method is designed for complex application, allowing them to have
      # different settings at the group level and not only at the user level.
      #
      # @return
      #   API GUID are represented as strings of 36 characters in the following
      #   form: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx where x is an hexadecimal
      #   digit ([0-9][a-f]).
      #
      # If a connection or protocol error arise, an Error is raised.
      #
      def get_guid
        @handle.call('get_guid', @user, @password)
      end
    end
  end
end
