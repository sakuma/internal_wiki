# coding: utf-8
module WikiInformationDecorator

  def private_policy
    is_private ? "限定公開" : "公開"
  end

end
