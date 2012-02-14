require 'spec_helper'

describe "Group Membership Requests" do
  let(:meg) { FactoryGirl.create(:meg) }

  context "as a group member" do
    include_context "signed in as a group member"
    let(:gmr) { GroupMembershipRequest.create({group: current_group, user: meg}) }

    describe "viewing the requests" do
      it "should refuse" do
        visit group_membership_requests_path(gmr.group)
        page.should have_content("You are not authorised to access that page.")
      end
    end
  end

  context "as a committee member" do
    include_context "signed in as a committee member"
    let(:gmr) { GroupMembershipRequest.create({group: current_group, user: meg}) }

    describe "confirming a request" do
      it "should send a notification" do
        visit group_membership_requests_path(gmr.group)
        click_on "Confirm"
        open_email(gmr.user.email)
        current_email.should have_subject("You are now a member of #{gmr.group.name}")
      end

      it "should not html escape the name of the group" do
        current_group.name = "A & B"
        current_group.save
        visit group_membership_requests_path(gmr.group)
        click_on "Confirm"
        open_email(gmr.user.email)
        current_email.should have_body_text("A & B")
      end
    end
  end

  context "as the original user" do
    include_context "signed in as a site user"
    let(:group) { FactoryGirl.create(:group) }

    before do
      visit group_path(group)
      click_link I18n.t(".groups.show.join_this_group")
      click_button "Create Group membership request"
    end

    describe "cancelling the request" do
      it "should cancel the request"
    end

    describe "signing up again" do
      it "should not show a link on the page" do
        visit group_path(group)
        page.should_not have_content(I18n.t(".groups.join_this_group"))
        page.should have_content(I18n.t(".groups.show.group_request_pending"))
      end

      it "should not let you go directly" do
        visit new_group_membership_request_path(group)
        click_button "Create Group membership request"
        page.should have_content(I18n.t(".group.membership_requests.create.already_asked"))
      end
    end
  end

  context "as a different user" do
    describe "cancelling the request" do
      it "should not cancel the request"
    end
  end
end
