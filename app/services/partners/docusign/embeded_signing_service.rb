module Partners
  module Docusign
    class EmbededSigningService
      def initialize(signer_email:, signer_name:, session:)
        @signer_email = signer_email.gsub(/([^\w \-\@\.\,])+/, '')
        @signer_name = signer_name.gsub(/([^\w \-\@\.\,])+/, '')
        @args = {
          account_id: session[:ds_account_id],
          base_path: session[:ds_base_path],
          access_token: session[:ds_access_token]
        }
        # @ds_account_id = session[:ds_account_id]
        # @base_path = session[:ds_base_path]
        # @access_token = session[:ds_access_token]
      end

      def run
        # ds_ping_url = Rails.application.config.app_url
        ds_return_url = "http://localhost:3000/ds_common-return"
        signer_client_id = 1000
        pdf_filename = 'dummy.pdf'

        # Step 1. Define the envelope & it's contents
        envelope = make_envelope(signer_client_id, pdf_filename)

        # Step 2. Send the envelope definition to DocuSign
        envelope_api = create_envelope_api(@args)

        remote_envelope = envelope_api.create_envelope args[:account_id], envelope
        envelope_id = remote_envelope.envelope_id
        # Save `envelope_id` for future use within the example launcher

        # Step 3. Create the recipient view for the embeded signing
        view_request = make_recipient_view_request( signer_client_id,
                                                    ds_return_url,
                                                    ds_ping_url )
        # Step 4. Call the CreateRecipientView API
        remote_view_request = envelope_api.create_recipient_view( args[:account_id],
                                                                  envelope_id,
                                                                  view_request )
        # Step 5. Redirect the user to the embedded signing
        # DocuSign recommends not iframing this! Need to look into that though-- GitHub iframes DocuSign
        # Maybe we can do a redirect?
        results.url
      end

      private

      def create_envelope_api(args)
        configuration = DocuSign_eSign::Configuration.new
        configuration.host = args[:base_path]
        api_client = DocuSign_eSign::ApiClient.new configuration
        api_client.default_headers['Authorization'] = "Bearer #{args[:access_token]}"
        DocuSign_eSign::EnvelopesApi.new api_client
      end

      def make_envelope(signer_client_id, pdf_filename)
        envelope_definition = DocuSign_eSign::EnvelopeDefinition.new
        envelope_definition.email_subject = "Please sign this document sent from Ruby SDK"

        doc1 = DocuSign_eSign::Document.new
        doc1.document_base64 = Base64.encode64(File.binread(File.join('public', pdf_filename)))
        doc1.name = 'Lorem Ipsum'
        doc1.file_extension = 'pdf'
        doc1.document_id = '1'

        # The order in the docs array determines the order in the envelope
        envelope_definition.documents = [doc1]
        # Create a signer recipient to sign the document, identified by name and email
        # We're setting the parameters via the object creation
        signer1 = DocuSign_eSign::Signer.new(
          email: @signer_email,
          name: @signer_name,
          clientUserId: signer_client_id,
          recipientId: 1
        )
        # The DocuSign platform searches throughout your envelope's documents
        # for matching anchor strings. So the sign_here_2 tab will be used in
        # both document 2 and 3 since they use the same anchor string for their
        # "signer 1" tabs.
        sign_here = DocuSign_eSign::SignHere.new
        sign_here.anchor_string = '/sn1/'
        sign_here.anchor_units = 'pixels'
        sign_here.anchor_x_offset = '20'
        sign_here.anchor_y_offset = '10'
        # Tabs are set per recipient/signer
        tabs = DocuSign_eSign::Tabs.new
        tabs.sign_here_tabs = [sign_here]
        signer1.tabs = tabs
        # Add the recipients to the envelope object
        recipients = DocuSign_eSign::Recipients.new
        recipients.signers = [signer1]

        envelope_definition.recipients = recipients
        # Request that the envelope be sent by setting status to "sent"
        # To request that the envelope be created as a draft, set status to "created"
        envelope_definition.status = "sent"
        envelope_definition
      end
    end
  end
end