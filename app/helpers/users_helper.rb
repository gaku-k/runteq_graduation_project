module UsersHelper
  def masked_email(email)
    name, domain = email.split("@")
    # ("*" * (name.lengh - 1))　："*" を (name.lengh - 1)回繰り返す
    masked_name = name[0] + ("*" * (name.size - 1))
    "#{masked_name}@#{domain}"
  end
end
