class jenkins {
  apt::sources_list { jenkins:
    content => "deb http://pkg.jenkins-ci.org/debian binary/",
    require => Apt::Key_local[jenkins]
  }

  apt::key_local { jenkins:
    key => "D50582E6",
    source => "puppet:///modules/jenkins/apt.key"
  }

  file { "/var/lib/jenkins/.gitconfig":
    owner => jenkins,
    content => "[user]\nemail = jenkins@dummy.priv\nname = Jenkins\n",
    require => Package[jenkins]
  }

  package { 'jenkins':
    require => Apt::Sources_list[jenkins]
  }

  if $debian::squeeze {
    apt::preferences { 'jenkins':
      before => Package['jenkins'],
      content => "Explanation:
Package: jenkins
Pin: version 1.611
Pin-Priority: 1000"
    }
  }

  service { jenkins:
    ensure => running,
    require => [Package[jenkins], File["/etc/default/jenkins"]]
  }

  file { "/etc/default/jenkins":
    source => 'puppet:///modules/jenkins/jenkins.default',
    notify => Service[jenkins]
  }

  file { "/var/lib/jenkins":
    owner => jenkins,
    ensure => directory,
    mode => 755,
    require => Package[jenkins]
  }
}
