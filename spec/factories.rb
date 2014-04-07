$logo = nil
FactoryGirl.define do

	sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:name) { |n| "Name#{n}" }
  sequence(:username) { |n| "User#{n}" }
	sequence(:businessname) { |n| "Business Number#{n}" }
  sequence(:phone_number) { |n| "555-#{((n % 9).to_s * 3)}-#{n.to_s.rjust(4,'0')}"  }
  sequence(:url) { |n| "http#{ n % 2 == 1 ? "s" : ""}//domain#{n}.#{ %w{ com org net sexy }[ n % 4 ] }"  }

  factory :user do
    name { generate :username }
    email { generate :email }
    uid { generate :email }

    trait :with_phone do
      phone_number { generate :phone_number }
    end

    trait :admin do
      roles [:admin]
    end
  end

  factory :refiddle_pattern do
    regex "/./"    
  end

  factory :refiddle do
    pattern { build :refiddle_pattern }
  end

  
end
