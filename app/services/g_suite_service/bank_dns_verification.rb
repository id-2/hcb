# frozen_string_literal: true

require 'resolv'

module GSuiteService
  class BankDnsVerification
    def initialize(g_suite_id:)
      @g_suite_id = g_suite_id
    end

    def generate
      {
        domain: domain,
        value: correct_record
      }
    end

    def verify
      bank_record = dns.map(&:strings).flatten
                       .select { |s| s.starts_with?('hack-club-bank-verification') }
                       .first


      verified = if bank_record.present?
                   bank_record.strip == correct_record
                 else
                   false
                 end

      result = {
        verified: verified,
        domain: domain,
        value: bank_record,
        expected_value: correct_record
      }

      result
    end

    private

    def correct_record
      "hack-club-bank-verification=#{gsuite.hashid}"
    end

    def gsuite
      @gsuite ||= GSuite.find(@g_suite_id)
    end

    def domain
      gsuite.domain
    end

    def dns
      @dns ||= Resolv::DNS.open do |dns|
        dns.timeouts = 1 # timeout after 1 second
        records = dns.getresources(domain, Resolv::DNS::Resource::IN::TXT)
      end
    end

  end
end
