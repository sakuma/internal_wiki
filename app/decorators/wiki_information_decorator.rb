# coding: utf-8
module WikiInformationDecorator

  def private_policy
    is_private ? "限定公開" : "公開"
  end


  def controllable_by?(user)
    return true if user.admin?
    collaborator_for_private_wiki?(user)
  end

end
