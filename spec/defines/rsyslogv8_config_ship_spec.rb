require 'spec_helper'

describe 'rsyslogv8::config::ship' do

  let (:title) { 'localhost' }

  context 'w/o global ssl' do
    let(:pre_condition) do
      "class { 'rsyslogv8': }"
    end

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'defaults' do
          let (:params) { {
          } }

          it { should contain_rsyslogv8__config__ship('localhost')
          }
        end

        context 'when using a wrong queue_mode' do
          let (:params) { {
            :queue_mode  => 'Error',
          } }

          it 'should fail' do
            expect { should contain_rsyslogv8__config__ship('localhost')
            }.to raise_error(Puppet::Error, /unknown value .* for parameter queue_mode*/)
          end
        end

        context 'when overriding ssl params' do
          context 'with TCP' do
            let (:params) { {
              :protocol          => 'tcp',
              :override_ssl      => true,
              :override_ssl_ca   => '/tmp/dummpy.pem',
              :override_ssl_cert => '/tmp/dummpy.pem',
              :override_ssl_key  => '/tmp/dummpy.pem',
            } }

            it 'should fail' do
              expect { should contain_rsyslogv8__config__ship('localhost')
              }.to raise_error(Puppet::Error, /cannot override ssl parameters for plain tcp connection/)
            end
          end

          context 'with RELP' do
            let (:params) { {
              :protocol          => 'relp',
              :override_ssl      => true,
              :override_ssl_ca   => '/tmp/dummpy.pem',
              :override_ssl_cert => '/tmp/dummpy.pem',
              :override_ssl_key  => '/tmp/dummpy.pem',
            } }

            if facts[:osfamily] == 'RedHat' and ( facts[:operatingsystemmajrelease] == '5' or facts[:operatingsystemmajrelease] == '6' )
              it 'should fail' do
                expect { should contain_rsyslogv8__config__ship('localhost')
                }.to raise_error(Puppet::Error, /TLS with relp does NOT work/)
              end
            else
              it { should contain_rsyslogv8__config__ship('localhost')
              }
            end
          end

          context 'with RELP and template' do
            let (:params) { {
              :protocol          => 'relp',
              :template          => 'FooBarTmpl',
              :override_ssl      => true,
              :override_ssl_ca   => '/tmp/dummpy.pem',
              :override_ssl_cert => '/tmp/dummpy.pem',
              :override_ssl_key  => '/tmp/dummpy.pem',
            } }
            if facts[:osfamily] == 'RedHat' and ( facts[:operatingsystemmajrelease] == '5' or facts[:operatingsystemmajrelease] == '6' )
              it 'should fail' do
                expect { should contain_rsyslogv8__config__ship('localhost')
                }.to raise_error(Puppet::Error, /TLS with relp does NOT work/)
              end
            else
              it {
                should contain_rsyslogv8__config__ship('localhost')
                should contain_file('/etc/rsyslog.d/90-ship-localhost.conf').with_content(/template="FooBarTmpl"/)
              }
            end
          end

          context 'with UDP' do
            let (:params) { {
              :protocol          => 'udp',
              :override_ssl      => true,
              :override_ssl_ca   => '/tmp/dummpy.pem',
              :override_ssl_cert => '/tmp/dummpy.pem',
              :override_ssl_key  => '/tmp/dummpy.pem',
            } }

            it 'should fail' do
              expect { should contain_rsyslogv8__config__ship('localhost')
              }.to raise_error(Puppet::Error, /Cannot use ssl for udp connection/)
            end
          end

        end
      end
    end
  end

  context 'with global ssl' do
    let(:pre_condition) do
      "class { 'rsyslogv8': ssl => true, ssl_ca => '/etc/cert.pem' }"
    end

    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context 'defaults' do
          let (:params) { {
          } }

          it { should contain_rsyslogv8__config__ship('localhost')
          }
        end

        context 'when using a wrong queue_mode' do
          let (:params) { {
            :queue_mode  => 'Error',
          } }

          it 'should fail' do
            expect { should contain_rsyslogv8__config__ship('localhost')
            }.to raise_error(Puppet::Error, /unknown value .* for parameter queue_mode.*/)
          end
        end

        context 'setting x509/name authentication' do
          context 'using TCP' do
            let (:params) { {
              :remote_auth => 'x509/name',
              :protocol    => 'tcp',
            } }

            it { should contain_rsyslogv8__config__ship('localhost')
            }
          end

          context 'using RELP' do
            let (:params) { {
              :remote_auth => 'x509/name',
              :protocol    => 'relp',
            } }

            if facts[:osfamily] == 'RedHat' and ( facts[:operatingsystemmajrelease] == '5' or facts[:operatingsystemmajrelease] == '6' )
              it 'should fail' do
                expect { should contain_rsyslogv8__config__ship('localhost')
                }.to raise_error(Puppet::Error, /TLS with relp does NOT work/)
              end
            else
              it { should contain_rsyslogv8__config__ship('localhost')
              }
            end
          end

          #context 'using UDP' do
          #  let (:params) { {
          #    :remote_auth => 'x509/name',
          #    :protocol    => 'udp',
          #  } }

          #    it 'should fail' do
          #      expect { should contain_rsyslogv8__config__ship('localhost')
          #      }.to raise_error(Puppet::Error, /Cannot use ssl for udp connection/)
          #    end
          #end
        end

        context 'when overriding ssl params' do
          context 'with TCP' do
            let (:params) { {
              :protocol          => 'tcp',
              :override_ssl      => true,
              :override_ssl_ca   => '/tmp/dummpy.pem',
              :override_ssl_cert => '/tmp/dummpy.pem',
              :override_ssl_key  => '/tmp/dummpy.pem',
            } }

            it 'should fail' do
              expect { should contain_rsyslogv8__config__ship('localhost')
              }.to raise_error(Puppet::Error, /cannot override ssl parameters for plain tcp connection/)
            end
          end

          context 'with RELP' do
            let (:params) { {
              :protocol          => 'relp',
              :override_ssl      => true,
              :override_ssl_ca   => '/tmp/dummpy.pem',
              :override_ssl_cert => '/tmp/dummpy.pem',
              :override_ssl_key  => '/tmp/dummpy.pem',
            } }

            if facts[:osfamily] == 'RedHat' and ( facts[:operatingsystemmajrelease] == '5' or facts[:operatingsystemmajrelease] == '6' )
              it 'should fail' do
                expect { should contain_rsyslogv8__config__ship('localhost')
                }.to raise_error(Puppet::Error, /TLS with relp does NOT work/)
              end
            else
              it { should contain_rsyslogv8__config__ship('localhost')
              }
            end
          end

          context 'with UDP' do
            let (:params) { {
              :protocol          => 'udp',
              :override_ssl      => true,
              :override_ssl_ca   => '/tmp/dummpy.pem',
              :override_ssl_cert => '/tmp/dummpy.pem',
              :override_ssl_key  => '/tmp/dummpy.pem',
            } }

            it 'should fail' do
              expect { should contain_rsyslogv8__config__ship('localhost')
              }.to raise_error(Puppet::Error, /Cannot use ssl for udp connection/)
            end
          end
        end

      end
    end
  end
end
