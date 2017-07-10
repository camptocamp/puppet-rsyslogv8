#require 'spec_helper_acceptance'
#
#describe 'rsyslogv8' do
#  context 'ruleset for kafka actions' do
#    pp = <<-EOS
#      class { 'rsyslogv8':
#        modules_extras => { 'omkafka' => {} },
#      }
#      rsyslogv8::config::templates { 'test':
#        templates => [
#          {
#            'name' => 'test1',
#            'type' => 'list',
#            'list' => [
#              {
#                'type' => 'constant',
#                'value' => 'test',
#              },
#              {
#                'type' => 'property',
#                'name' => 'syslogfacility-text',
#                'regex.nomatchmode' => 'DFLT',
#                'regex.match' => "0",
#                # quadruple escaping rspec...
#                'regex.expression' => '(^[^\\\\\\\\.]*)',
#              }
#            ]
#          }
#        ]
#      }
#      rsyslogv8::config::ruleset { 'test':
#        actions => [
#          {
#            'type' => 'omkafka',
#            'name' => 'kafkasend',
#            'comment' => 'This is a one-line comment',
#            'topic' => 'foo',
#            'queue' => {
#              'type' => 'LinkedList',
#              'discard_mark' => '100',
#              'discard_severity' => 8,
#            },
#            'closeTimeout' => 4000,
#            'topicConfParam' => [
#              'test=2',
#              'test2=3',
#            ],
#            'template' => 'test1',
#            'key' => 'kafka',
#            'partitions.auto' => true,
#            'confParam' => [
#              'compression.codec=snappy',
#              'socket.timeout.ms=5',
#            ],
#          },
#          {
#            'type' => 'omkafka',
#            'name' => 'kafkasend',
#            'topic' => 'foo',
#            'partitions.number' => 3,
#            'errorFile' => '/var/log/error.log',
#            'broker' => [ 'test1:9092', 'test2:9092', 'test3:9092' ],
#            'comment' => 'This is a one-line comment',
#            'queue' => {
#              'type' => 'LinkedList',
#              'discard_mark' => '100',
#              'discard_severity' => 8,
#            },
#          },
#        ],
#      }
#    EOS
#    it 'should apply without error' do
#      apply_manifest(pp, :catch_failures => true)
#    end
#    it 'should idempotently run' do
#      apply_manifest(pp, :catch_changes => true)
#    end
#    # Kafka is not supported on RedHat 5 and Debian 6/7
#    if ! ( ( fact(:osfamily) == 'RedHat' and fact(:operatingsystemmajrelease) == '5' ) or ( fact(:osfamily) == 'Debian' and (fact(:operatingsystemmajrelease) == '6' or fact(:operatingsystemmajrelease) == '7') ) or ( fact(:operatingsystem) == 'Ubuntu' ) )
#      describe command('rsyslogd -N1') do
#        its(:exit_status) { should eq 0 }
#      end
#    end
#  end
#end
#
