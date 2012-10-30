require File.expand_path('../../../spec_helper', __FILE__)

module Pod
  describe Command::Setup do
    extend SpecHelper::TemporaryDirectory
    extend SpecHelper::TemporaryRepos

    before do
      config.repos_dir = SpecHelper.tmp_repos_path
    end

    it "runs with correct parameters" do
      lambda { run_command('setup') }.should.not.raise
    end

    it "complains for wrong parameters" do
      lambda { run_command('setup', 'wrong') }.should.raise CLAide::Help
      lambda { run_command('setup', '--wrong') }.should.raise CLAide::Help
    end

    it "returns the read only URL of the `master' spec-repo" do
      cmd = Command::Setup.new(argv)
      cmd.url.should == 'https://github.com/CocoaPods/Specs.git'
    end

    it "returns the push URL of the `master' spec-repo" do
      config.silent = true
      cmd = Command::Setup.new(argv('--push'))
      cmd.url.should == 'git@github.com:CocoaPods/Specs.git'
    end

    class Command::Setup
      def read_only_url; SpecHelper.fixture('spec-repos/master'); end
    end

    it "creates the local spec-repos directory and creates a clone of the `master' repo" do
      output = run_command('setup')
      output.should.include "Setup completed"
      output.should.not.include "push"
      git_config('master', 'remote.origin.url').should == fixture('spec-repos/master').to_s
    end

    it "preserves push access for the `master' repo" do
      output = run_command('setup')
      output.should.not.include "push"
      git('master', 'remote set-url origin git@github.com:CocoaPods/Specs.git')
      command('setup').url.should == 'git@github.com:CocoaPods/Specs.git'
    end

    it "can run if needed" do
      output = run_command('setup')
      output.should.include "Setup completed"
      UI.output = ''
      command('setup').run_if_needed
      UI.output.should == ''
    end
  end
end
