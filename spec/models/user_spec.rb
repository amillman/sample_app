require 'spec_helper'

describe User do
  before { @user = User.new name: "Example User", email:"user@example.com", password:"password", password_confirmation:"password" }
  subject { @user }
  it {should respond_to :name}
  it {should respond_to :email}
  it {should respond_to :password_digest}
  it {should respond_to :password}
  it {should respond_to :password_confirmation}
  it { should respond_to(:authenticate) }

  it {should be_valid}

  describe "when name is not present" do
    before { @user.name = "" }
    it {should_not be_valid}
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it {should_not be_valid}
  end

  describe "when email is not present" do
    before { @user.email = "" }
    it {should_not be_valid}
  end

  describe "when email is invalid" do
    it "should be invalid" do
      addresses = %w[ user@foo,com foo_bar.org example.user@foo.bar@bar.com foo@bar+bar.com ]
      addresses.each do |a|
        @user.email = a
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email is invalid" do
    it "should be valid" do
      addresses = %w[ user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn ]
      addresses.each do |a|
        @user.email = a
        expect(@user).to be_valid
      end
    end
  end

  describe "when email address is already taken" do
    before do
      same_user = @user.dup
      same_user.email = @user.email.upcase
      same_user.save
    end

    it{should_not be_valid}
  end

  describe "when password is not present" do
    before do
      @user = User.new name: "Example User", email: "user@example.com", password: " ", password_confirmation: " "
    end
    it {should_not be_valid}
  end

  describe "when password confirmation doesn't match original" do
    before {@user.password_confirmation = "mismatch"}
    it {should_not be_valid}
  end

  describe "too short password" do
    before {@user.password = "a" * 5}
    it {should_not be_valid}
  end

  describe "return value of authenticate method" do
    before {@user.save}
    let(:found_user) {User.find_by email: @user.email}

    describe "with valid password" do
      it {should eq found_user.authenticate(@user.password)}
    end

    describe "with invalid password" do
      let(:invalid) {found_user.authenticate("invalid")}

      it {should_not eq invalid}
      specify{expect(invalid).to be_false}
    end
  end

end