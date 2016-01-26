namespace :data do
  desc "TODO"
  task taxon_certify: :environment do
    100.times do |n|
      if n < 10
        phone = "1852000210#{n}"
      else
        phone = "185200021#{n}"
      end
      handman = Account.create({
        email: "abcd#{n}@qq.com",
        phone: phone,
        name:  "haha#{n}",
        password: "asdfgzxc",
        type: "Admin"
      })

      Taxon.create({
        handyman_id: handman.id,
        code: "electronic/lighting",
        cert_requested_at: Time.now
      })
    end
  end

end
