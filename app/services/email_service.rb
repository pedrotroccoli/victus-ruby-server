class EmailService
  def initialize()
    @client = Mailersend::Client.new(ENV['MAILERSEND_API_KEY'])
  end

  def send_welcome_email(account)
    email = Mailersend::Email.new(@client)
    email.add_recipients("email" => account.email.to_s, "name" => account.name.to_s)
    email.add_from("email" => "info@mail.victusjournal.com", "name" => "Victus Journal")
    email.add_subject("Bem vindo ao Victus Journal!")
    email.add_template_id("3yxj6lj5zexgdo2r")

    personalization = {
      email: account.email.to_s,
      data: {
        name: account.name.to_s,
        url: ENV['APP_URL']
      }
    }

    email.add_personalization(personalization)

    email.send

    rescue => e
      puts e
    end
  end
end
