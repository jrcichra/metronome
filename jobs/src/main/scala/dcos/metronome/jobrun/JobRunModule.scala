package dcos.metronome
package jobrun

import java.time.Clock

import akka.actor.{ ActorContext, ActorSystem, Props }
import dcos.metronome.measurement.MethodMeasurement
import dcos.metronome.jobrun.impl.{ JobRunExecutorActor, JobRunPersistenceActor, JobRunServiceActor, JobRunServiceDelegate }
import dcos.metronome.model.{ JobResult, JobRun, JobRunId }
import dcos.metronome.repository.Repository
import mesosphere.marathon.MarathonSchedulerDriverHolder
import mesosphere.marathon.core.launchqueue.LaunchQueue
import mesosphere.marathon.core.leadership.LeadershipModule
import mesosphere.marathon.core.task.tracker.InstanceTracker

import scala.concurrent.Promise

class JobRunModule(
  config:           JobRunConfig,
  actorSystem:      ActorSystem,
  clock:            Clock,
  jobRunRepository: Repository[JobRunId, JobRun],
  launchQueue:      LaunchQueue,
  instanceTracker:  InstanceTracker,
  driverHolder:     MarathonSchedulerDriverHolder,
  behavior:         MethodMeasurement,
  leadershipModule: LeadershipModule) {

  import com.softwaremill.macwire._

  private[this] def executorFactory(jobRun: JobRun, promise: Promise[JobResult]): Props = {
    val persistenceActorFactory = (id: JobRunId, context: ActorContext) =>
      context.actorOf(JobRunPersistenceActor.props(id, jobRunRepository, behavior))
    JobRunExecutorActor.props(jobRun, promise, persistenceActorFactory,
      launchQueue, instanceTracker, driverHolder, clock, behavior)(actorSystem.scheduler)
  }

  val jobRunServiceActor = leadershipModule.startWhenLeader(
    JobRunServiceActor.props(clock, executorFactory, jobRunRepository, behavior), "JobRunService")

  def jobRunService: JobRunService = behavior(wire[JobRunServiceDelegate])
}
