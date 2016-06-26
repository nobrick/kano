namespace :db do
  namespace :seed do
    desc "Load the seed data for admin taxon_ceritfy"
    task taxon_certify: :environment do
      100.times do |n|
        if n < 10
          phone = "1852000210#{n}"
        else
          phone = "185200021#{n}"
        end
        handyman = Account.create({
          email: "abcd#{n}@qq.com",
          phone: phone,
          name:  "haha#{n}",
          password: "asdfgzxc",
          type: "Admin"
        })

        Taxon.create({
          handyman_id: handyman.id,
          code: "electronic/lighting",
          cert_requested_at: Time.now
        })
      end
    end
  end
end
