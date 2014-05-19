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

class XMLRPC::Client
  def set_debug
  end
end

module NetOxygen

  module SMS

    # The Client class, using the XML-RPC API.
    class Client
      # the server host
      XMLRPC_API_URI = 'https://sms.netoxygen.ch/api2/'

      attr_reader :debug

      def initialize(user, password)
        @user     = user
        @password = password
        @debug    = false
        @handle   = XMLRPC::Client.new_from_uri(XMLRPC_API_URI)
        def @handle.set_debug flag
          @http.set_debug_output(flag ? $stderr : nil);
        end
      end

      def enable_debug
        @handle.set_debug(@debug = true)
        self
      end

      def disable_debug
        @handle.set_debug(@debug = false)
        self
      end

      def auth
        @handle.call('auth', @user, @password)
      end

      def send_message(to, message, from='', date='', type='text')
        @handle.call('send_message', @user, @password, [*to],
          message.encode('utf-8'), date, type.encode('utf-8'))
      end

      def cancel_message id
        @handle.call('cancel_message', @user, @password, [*id])
      end

      def get_status id
        @handle.call('get_status', @user, @password, [*id])
      end

      def get_credits
        @handle.call('get_credits', @user, @password)
      end

      def account_status
        @handle.call('get_credits', @user, @password)
      end

      def get_guid
        @handle.call('get_guid', @user, @password)
      end
    end
  end
end
